//= require can.jquery-all
//= require sections/section
//= require controls/control

(function(namespace, $) {
function mapunmap(unmap) {
  return function(section, rcontrol, ccontrol) {
      var params = {
        ccontrol : (ccontrol ? ccontrol.id : "")
      };
      if(unmap)
        params.u = "1";
      if(rcontrol) params.rcontrol = rcontrol.id;
      if(section) params.section = section.id;

      var dfd = section ? 
        section.map_rcontrol(params)
        : rcontrol.map_ccontrol(params);
      dfd.then(can.proxy(this.updateButtons, this));
      return dfd;
  }  
}


can.Control("CMS.Controllers.Mapping", {
  //static
  cache : {}
}, {
  init : function() {
    this.link_lists();
    this.updateButtons();
  }

  , link_lists : function() {
      $.when(
        this.options.company_list_controller.find_all_deferred
        , this.options.reg_list_controller.find_all_deferred
        , this.options.section_list_controller.find_all_deferred
      ).done(function() {

        can.each(CMS.Models.RegControl.cache, function(rcontrol, id) {
          rcontrol.attr("implementing_controls", new can.Model.List(
            can.$(rcontrol.implementing_controls).map(function(index, ictl){
              return CMS.Models.Control.findInCacheById(ictl.id);
          })));
        }); 

        can.each(CMS.Models.SectionSlug.cache, function(section, id) {
          var implementing_control_ids = []
          , ctls_list = section.linked_controls;

          can.each(ctls_list, function(ctl) {
            var ctl_model = namespace.CMS.Models.RegControl.findInCacheById(ctl.id);
            if(ctl_model && ctl_model.implementing_controls && ctl_model.implementing_controls.length) {
              implementing_control_ids = implementing_control_ids.concat(
                can.map(ctl_model.implementing_controls, function(ictl) { return ictl.id })
              );
            }
          });
          var controls = new can.Model.List();
          can.each(ctls_list, function(ctl) {
            if(can.inArray(ctl.id, implementing_control_ids) < 0) {
              var rctl = CMS.Models.RegControl.findInCacheById(ctl.id);
              controls.push(rctl);
              rctl.bind_section(section); 
            } else {
              controls.push(CMS.Models.Control.findInCacheById(ctl.id));
            }
          });
          section.attr("linked_controls", controls);
        });

      });

  }

  , "#rmap, #cmap click" : function(el, ev) {
    var that = this;
    var section = $("#selected_sections").control(namespace.CMS.Controllers.Sections).options.instance;
    var rcontrol = $("#selected_rcontrol").control(namespace.CMS.Controllers.Controls).options.instance;
    var ccontrol = $("#selected_ccontrol").control(namespace.CMS.Controllers.Controls).options.instance;

    if(el.is("#cmap")) {
      section = null;
    }
    var dfd = this[el.is(".unmapbtn") ? "unmap" : "map"](section, rcontrol, ccontrol); 
    var that = this;
    dfd.then(function() { 
      that.options.section_list_controller.draw_list(); //manual update because section model doesn't contain "real" rcontrol model
    });

    if(!rcontrol && el.is("#rmap")) {
      var notice, reg_slug;
      dfd.then(function(resp, status, xhr) {
        notice = /.*Created regulation control (.+)\. Mapped regulation control\. */.exec(xhr.getResponseHeader("X-Flash-Notice"));
        if(notice) 
          reg_slug = notice[1];
      })
      dfd.then($.proxy(this.options.reg_list_controller, "fetch_list"))
      .then(function() {
        that.options.reg_list_controller.find_all_deferred.then(function(list) {
          section.addElementToChildList("linked_controls", can.filter(can.makeArray(list), function(item) { return item.slug === reg_slug })[0]);
        })
        .then($.proxy(that, "link_lists"));
      });
    }
  }  

  , unmap : function() { return mapunmap(true).apply(this, arguments); }
  , map : function() { return mapunmap(false).apply(this, arguments); }

  , "#rcontrol_list .regulationslot click" : function(el, ev) {
    CMS.Controllers.Controls.Instances.SelectedRegControl.update({ instance : el.closest("[data-model]").data("model") });
    this.updateButtons();
    ev.preventDefault();
  }

  , "#ccontrol_list .regulationslot click" : function(el, ev) {
    CMS.Controllers.Controls.Instances.SelectedCompanyControl.update({ instance : el.closest("[data-model]").data("model") });
    this.updateButtons();
    ev.preventDefault();
  }

  , "#section_list .regulationslot click" : function(el, ev) {
    CMS.Controllers.Sections.Instances.SelectedSection.update({ instance : el.closest("[data-model]").data("model") });
    this.updateButtons();
    ev.preventDefault();
  }

  , updateButtons : function(ev, oldVal, newVal) {
    var section = $("#selected_sections").control(namespace.CMS.Controllers.Sections).options.instance;
    var rcontrol = $("#selected_rcontrol").control(namespace.CMS.Controllers.Controls).options.instance;
    var ccontrol = $("#selected_ccontrol").control(namespace.CMS.Controllers.Controls).options.instance;
    
    var rmap = $('#rmap');
    var cmap = $('#cmap');

    rmap.attr('disabled', !(section && (rcontrol || ccontrol)));
    if (!(section && (rcontrol || ccontrol))) {
      rmap.children(':first').text('Map section to control');
    }
    cmap.attr('disabled', !(rcontrol && ccontrol));
    if (!(rcontrol && ccontrol)) {
      cmap.children(':first').text('Map control to control');
    }

    if ((section && (rcontrol || ccontrol)) || (rcontrol && ccontrol)) {
          var rmap_text = $(rmap.children()[0]);
          var cmap_text = $(cmap.children()[0]);
          var runmap = section && rcontrol ? $(section.linked_controls).filter(function() { return this.id  === rcontrol.id}).length : false;
              runmap || (runmap = section && !rcontrol && ccontrol ? $(section.linked_controls).filter(function() { return this.id === ccontrol.id}).length : false);
          var cunmap = rcontrol && ccontrol ? $(rcontrol.implementing_controls).filter(function() { return this.id === ccontrol.id}).length : false;

          // We don't know how we'd unmap a ccontrol directly from a section, because there's an auto-generated
          //  rcontrol associated with it.  So don't allow it.
          if(section && !rcontrol && runmap) {
            rmap.attr("disabled", true);
          }

          rmap_text.text(runmap ? 'Unmap' : 'Map section to control')
          rmap[runmap ? 'addClass' : "removeClass"]("unmapbtn");
          cmap_text.text(cunmap ? 'Unmap' : 'Map control to control')
          cmap[cunmap ? 'addClass' : "removeClass"]("unmapbtn");
    }
  }
  , ".clearselection click" : function(el, ev) {
    this.updateButtons();
  }

  // Post-submit handler for new control dialog
  , "#new_control ajax:json" : function(el, ev, data) {
    if(data.program_id.toString() === this.options.id) {
      // add this control to the reg controls.
      // This isn't the best way to go about it, but CanJS/Mustache is currently ornery about accepting new observable list elements
      //  added with "push" --BM 12/11/2012
      var rctl = this.options.reg_list_controller;
      can.Model.Cacheable.prototype.addElementToChildList.call(rctl.options.observer, "list", new namespace.CMS.Models.RegControl(data));
    }
    var cctl = this.options.company_list_controller;
    can.Model.Cacheable.prototype.addElementToChildList.call(cctl.options.observer, "list", new namespace.CMS.Models.Control(data));
  }

  , "a.controllist, a.controllistRM click" : function(el, ev) {
    var $dialog = $("#mapping_dialog");
    if(!$dialog.length) {
      $dialog = $('<div id="mapping_dialog" class="modal hide"></div>')
        .appendTo(this.element)
        .draggable({ handle: '.modal-header' });
    }

    ev.preventDefault();
    $dialog.html(can.view("/sections/controls_mapping.mustache", el.closest("[data-model]").data("model")));
    $dialog.modal_form({ backdrop: false }).modal_form('show');
  }

  , "#mapping_dialog .closebtn click" : function(el) {
    el.closest("#mapping_dialog").modal_form('hide');
  }

  , "#mapping_dialog .unmapbtn click" : function(el) {
    var thiscontrol = el.data("id")
    , _section = namespace.CMS.Models.SectionSlug.findInCacheById(el.closest("[data-section-id]").data("section-id"))
    , that = this
    , $rc, rcontrol, ccontrol, section;
    if(($rc = el.closest("[data-rcontrol-id]")).length > 0) {
      rcontrol = namespace.CMS.Models.RegControl.findInCacheById($rc.data("rcontrol-id"));
      ccontrol = namespace.CMS.Models.Control.findInCacheById(thiscontrol);
    } else {
      rcontrol = namespace.CMS.Models.RegControl.findInCacheById(thiscontrol);
      section = _section;
    }
    this.unmap(section, rcontrol, ccontrol)
    .then(function() {
      var implementing_control_ids = []
      , ctls_list = _section.linked_controls
      , lcs = new can.Model.List();

      can.each(ctls_list, function(ctl_model) {
        if(ctl_model && ctl_model.implementing_controls && ctl_model.implementing_controls.length) {
          implementing_control_ids = implementing_control_ids.concat(
            can.map(ctl_model.implementing_controls, function(ictl) { return ictl.id })
          );
        }
      });
      can.each(ctls_list, function(ctl) {
        if($.inArray(ctl.id, implementing_control_ids) > -1) {
          lcs.push(CMS.Models.Control.findInCacheById(ctl.id));
        } else {
          lcs.push(CMS.Models.RegControl.findInCacheById(ctl.id));
        }
      });
      _section.attr("linked_controls", lcs);
      var $dialog = $("#mapping_dialog");
      $dialog.html(can.view("/sections/controls_mapping.mustache", _section));
      that.options.section_list_controller.draw_list();
    });
  }

  , "#section_na click" : function(el, ev) {
    var section = namespace.CMS.Models.SectionSlug.findInCacheById(el.closest("[data-section-id]").data("section-id"));
    section.attr("na", el.attr("checked") ? 1 : 0);
    section.save();
  }

  , "#section_notes change" : function(el, ev) {
    var section = namespace.CMS.Models.SectionSlug.findInCacheById(el.closest("[data-section-id]").data("section-id"));
    section.attr("notes", el.val());
    section.save();
  }

});

can.Control("CMS.Controllers.MappingWidgets", {}, {

  ".clearselection click" : function(el, ev) {
    var controllers = this.element.find(".cms_controllers_controls, .cms_controllers_sections").controls(namespace.CMS.Controllers.Controls);
    $(controllers).each(function() {
      if(this.options.arity === 1) {
        this.update({instance : null});
      } else {
        this.setSelected(null);
      }
    });
  }

  , ".widgetsearch-tocontent keydown" : function(el, ev) {
    var controllers = this.element.find(".cms_controllers_controls, .cms_controllers_sections").controls(namespace.CMS.Controllers.Controls);
    $(controllers).each(function() {
      var that = this;
      setTimeout(function() {
        if(that.options.arity > 1) {
          that.filter(el.val());
        }
      }, 1);
    });
    ev.stopPropagation();
  }

});

})(this, can.$);
