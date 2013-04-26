//= require can.jquery-all
//= require sections/section
//= require controls/control
//= require controls/controls_controller

(function(namespace, $) {
function mapunmap(unmap) {
  return function(section, rcontrol, ccontrol) {
      var params = {
        ccontrol : (ccontrol ? ccontrol.id : "")
      };
      if(unmap)
        params.u = "1";
      if(rcontrol) params.rcontrol = rcontrol.id;
      if(rcontrol === null) params.rcontrol = ccontrol.id;
      if(section) params.section = section.id;

      var dfd = section ?
        section["map_" + (rcontrol === null ? "control" : "rcontrol")](params)
        : rcontrol.map_ccontrol(params);
      dfd.done(can.proxy(this.updateButtons, this));
      return dfd;
  }
}


can.Control("CMS.Controllers.Mapping", {
  //static
  cache : {}
  , defaults : {
    section_model : namespace.CMS.Models.SectionSlug
  }
}, {
  init : function() {
    this.link_lists();
    this.updateButtons();
  }

  , link_lists : function() {
    var that = this;
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

        can.each(that.options.section_model.cache, function(section, id) {
          section.update_linked_controls();
        });

      });

  }

  , "#rmap:not([disabled]), #cmap:not([disabled]) click" : function(el, ev) {
    var that = this;
    var section = can.getObject("options.instance", $("#selected_sections").control(namespace.CMS.Controllers.Sections));
    var rcontrol = can.getObject("options.instance", $("#selected_rcontrol").control(namespace.CMS.Controllers.Controls));
    var ccontrol = can.getObject("options.instance", $("#selected_ccontrol").control(namespace.CMS.Controllers.Controls));

    if(el.is("#cmap")) {
      section = null;
    }
    var dfd = this[el.is(".unmapbtn") ? "unmap" : "map"](section, rcontrol, ccontrol);
    this.bindXHRToButton(dfd, el);
    dfd.always(this.proxy("updateButtons")); //bindXHR will remove the disabled attr, so re-check afterwards.
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
          var ccontrol = section.linked_controls[section.linked_controls.length - 1];
          section.removeElementFromChildList("linked_controls", ccontrol);
          section.addElementToChildList("linked_controls", can.filter(can.makeArray(list), function(item) { return item.slug === reg_slug })[0]);
          section.addElementToChildList("linked_controls", ccontrol); //adding the reg control in before the ccontrol is necessary because we
                                                                      // are assuming order when updating linkages
        });
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
    var section = can.getObject("options.instance", $("#selected_sections").control(namespace.CMS.Controllers.Sections));
    var rcontrol = can.getObject("options.instance", $("#selected_rcontrol").control(namespace.CMS.Controllers.Controls));
    var ccontrol = can.getObject("options.instance", $("#selected_ccontrol").control(namespace.CMS.Controllers.Controls));

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
  , "a[href^='/controls/new'] modal:success" : function(el, ev, data) {
    var item;
    if($(el).closest("#mapping_rcontrols_widget").length) {
      // add this control to the reg controls.
      // This isn't the best way to go about it, but CanJS/Mustache is currently ornery about accepting new observable list elements
      //  added with "push" --BM 12/11/2012
      var rctl = this.options.reg_list_controller;
      item = namespace.CMS.Models.RegControl.model(data);
      rctl.options.observer.list.splice(this.slug_sort_position(item, rctl.options.observer.list), 0, item);
    } else {
      var cctl = this.options.company_list_controller;
      item = namespace.CMS.Models.Control.model(data);
      cctl.options.observer.list.splice(this.slug_sort_position(item, cctl.options.observer.list), 0, item);
    }
    var $item = $("[content_id=" + item.content_id + "]");
    var $content = $item.closest(".content");
    $item.find("a").click();
    $content.scrollTop($item.offset().top - $content.offset().top - ($content.height() - $item.height()) / 2)
    this.element.find(".search-results-count").html(+(this.element.find(".search-results-count").html()) + 1);
  }

  , slug_sort_position : function(data, list) {
    var pos = list.length;
    can.each(list, function(item, i) {
      if(window.natural_comparator(data, item) < 1) {
        pos = i;
        return false;
      }
    });
    return pos;
  }

  , "a.controllist, a.controllistRM click" : function(el, ev) {
    var $dialog = $("#mapping_dialog");
    if(!$dialog.length) {
      $dialog = $('<div id="mapping_dialog" class="modal hide"></div>')
        .appendTo(this.element)
        .draggable({ handle: '.modal-header' });
    }

    ev.preventDefault();
    // Not putting in the real model because live binding is having a problem with how we do things.
    $dialog.html(can.view("/assets/sections/controls_mapping.mustache", el.closest("[data-model]").data("model").serialize()));
    $dialog.modal_form({ backdrop: true }).modal_form('show');
  }

  , "#mapping_dialog .closebtn click" : function(el) {
    el.closest("#mapping_dialog").modal_form('hide');
  }

  , "#mapping_dialog .unmapbtn click" : function(el, ev) {
    var thiscontrol = el.data("id")
    , _section = this.options.section_model.findInCacheById(el.closest("[data-section-id]").data("section-id"))
    , that = this
    , $rc, rcontrol, ccontrol, section;
    if(($rc = el.closest("[data-rcontrol-id]")).length > 0) {
      rcontrol = namespace.CMS.Models.RegControl.findInCacheById($rc.data("rcontrol-id"));
      ccontrol = namespace.CMS.Models.Control.findInCacheById(thiscontrol);
    } else {
      rcontrol = namespace.CMS.Models.RegControl.findInCacheById(thiscontrol);
      section = _section;
    }
    this.bindXHRToButton(
      this.unmap(section, rcontrol, ccontrol)
        .then(function() {
          _section.update_linked_controls();
          var $dialog = $("#mapping_dialog");
          $dialog.html(can.view("/assets/sections/controls_mapping.mustache", _section.serialize()));
          that.options.section_list_controller.draw_list();
        }),
      el);
  }

  , "#section_na click" : function(el, ev) {
    var section = this.options.section_model.findInCacheById(el.closest("[data-section-id]").data("section-id"));
    section.attr("na", el.attr("checked") ? 1 : 0);
    this.bindXHRToButton(section.save(), el);
  }

  , "#section_notes change" : function(el, ev) {
    var section = this.options.section_model.findInCacheById(el.closest("[data-section-id]").data("section-id"));
    section.attr("notes", el.val());
    this.bindXHRToButton(section.save(), el);
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
      if(that.search_timeout) clearTimeout(that.search_timeout);
      that.search_timeout = setTimeout(function() {
        if(that.options.arity > 1) {
          that.filter(el.val());
        }
      }, 300);
    });
    ev.stopPropagation();
  }

});
  //---------------------------------------------------------------
  // Below this line is new development for killing the reg mapper
  //---------------------------------------------------------------
CMS.Controllers.Mapping("CMS.Controllers.ControlMappingPopup", {
  defaults : {
    section_model : namespace.CMS.Models.SectionSlug
    , parent_model : namespace.CMS.Models.Program
    , parent_id : null
    , observer : undefined
    , section : null
  }
  //static
}, {
  init : function() {
    var that = this;
    if(this.element.find(".spinner").length < 1)
      this.element.append($(new Spinner().spin().el).css({"position" : "relative", "left" : 50, "top" : 50, "height": 150, "width": 150}));
    this.options.observer = new can.Observe({
      section : this.options.section
      , parent_type : this.options.parent_model.root_object
      , parent_subtype : can.underscore(this.options.parent_model.shortName).replace("_", " ")
      , parent_id : this.options.parent_id
    });

    can.view("/assets/sections/control_selector.mustache", that.options.observer, function(frag) {
      that.options.company_list_controller = that.element
      .html(frag).trigger("shown")
      .find(".controls-list")
      .cms_controllers_controls({
        list : "/assets/controls/list_selector.mustache"
        , show : "/assets/controls/show_selector.mustache"
        , arity : 2})
      .control();

      that.options.selected_control_controller = that.element
      .find(".selector-info.control")
      .append($(new Spinner().spin().el).css({"position" : "relative", "left" : 50, "top" : 50, "height": 150, "width": 150}))
      .cms_controllers_controls({show : "/assets/controls/show_selected_sidebar.mustache", arity : 1})
      .control();

      that.search_filter(that.options.company_list_controller.find_all_deferred).done(function(d) {
        that.list = d;
        that.options.section.update_linked_controls_ccontrol_only();
        //that.options.observer.attr("controls", d);
        that.update();
        that.element.trigger("shown").trigger("kill-all-popoevers");
      });
    });

    this.on();
  }

  , update : function() {
    var section = this.options.section;
    this.options.observer.attr("section", section);
    this.element.find(".controls-list ul > [data-model]").each(this.proxy("style_item"));
  }

  , style_item : function(el) {
    if(arguments.length === 2 && typeof arguments[0] === "number") {  //jQuery "each" case
      el = arguments[1];
    }

    if(~can.inArray($(el).data("model"), this.options.section.linked_controls)) {
      $(el).find("input[type=checkbox]").prop("checked", true);
    } else {
      $(el).find("input[type=checkbox]").prop("checked", false);
    }
  }

  , " hidden" : function() {
      this.element.remove();
  }

  , "input.map-control change" : function(el, ev) {
    var that = this
    , control = el.closest("[data-model]").data("model")
    , is_mapped = !!~can.inArray(control, this.options.section.linked_controls);

    if(is_mapped ^ el.prop("checked")) {
      this[is_mapped ? "unmap" : "map"](this.options.section, null, control)
      .done(function() {
        setTimeout(function() {
          that.style_item(that.element.find("[content_id=" + control.content_id + "]").parent());
        }, 10)
      });
    }
  }

  // , "{section} updated" : function(obj, ev) {
  //   // if(!/(^|\.)linked_controls(\.|$)/.test(attr))
  //   //   return;
  //   var $count = $("#content_" + obj.slug).find("> .item-main .controls-count")
  //     , html;
  //   if (obj.linked_controls.length > 0) {
  //     html = "<i class='grcicon-control-color'></i> " + obj.linked_controls.length;
  //   } else if (obj.na) {
  //     html = "<i class='grcicon-control-color'></i> <small class='warning'>N/A</small>";
  //   } else {
  //     html = "<i class='grcicon-control-danger'></i> <strong class='error'>0</strong>";
  //   }
  //   $count.html(html);
  //   var data = obj.linked_controls.length ? obj.linked_controls.serialize() : {na : obj.na};
  //   var render_str = can.view.render("/assets/controls/list_popover.mustache", data);
  //   $count.attr("data-content", render_str).data("content", render_str)
  //   this.update();
  // }

  , ".edit-control modal:success" : function(el, ev, data) {
    el.closest("[data-model]").data("model").attr(data).updated();
  }

  , ".widgetsearch-tocontent keydown" : function(el, ev) {
    if(ev.which === 13) {
      this.search_filter();
    }
  }

  , ".control-type-filter change" : "search_filter"

  , search_filter : function(dfd) {
    var that = this;
    var check = { ids_only: true };
    if(this.element.find(".control-type-filter").prop("checked")) {
      check[this.options.parent_model.root_object + "_id"] = this.options.parent_id;
    }
    var search = this.element.find(".widgetsearch-tocontent").val();
    
    return this.options.company_list_controller
    .filter(search, check, dfd)
    .done(function(d) {
      that.element.find(".search-results-count").html(d.length);
      that.update_map_all();
    });
  }

  , redo_last_search : function(id_to_add) {
    var that = this;
    this.options.company_list_controller.redo_last_filter(id_to_add).done(function(d){
      that.element.find(".search-results-count").html(d.length);
      that.update_map_all();
    });
  }

  , "a[href^='/controls/new'] modal:success" : function(el, ev, data) {
    var that = this
    , model;
    this._super(el, ev, data);
    model = CMS.Models.Control.model(data);
    this.redo_last_search(model.id);
    this.map(this.options.section, null, model).done(function() {
      that.update();
    });
  }

  , ".search-reset click" : function(el, ev) {
    this.element.find(".widgetsearch-tocontent").val("");
    this.search_filter();
  }

  , ".item-main click" : function(el, ev) {
    this.options.selected_control_controller.update({"instance" : el.closest("[data-model]").data("model")});
    this.element.find(".control").removeClass("selected");
    el.closest(".control").addClass("selected");
  }

  , update_map_all : function() {
    this.element.find(".map-all").prop("checked", !this.element.find(".item-main:visible input:not(:checked)").length);
  }

  , ".map-all click" : function(el, ev) {
    var that = this;
    var dfds = [];
    if(el.prop("checked")) {
      //map
      this.element.find(".control:visible:has(input:not(:checked))").each(function(i, val) {
        dfds.push(that.map(that.options.section, null, $(val).data("model")).then(function(d) {
          that.style_item(val);
          return d;
        }));
      });
    } else {
      //unmap
      this.element.find(".control:visible:has(input:checked)").each(function(i, val) {
        dfds.push(that.unmap(that.options.section, null, $(val).data("model")).then(function(d) {
          that.style_item(val);
          return d;
        }));
      });
    }
    $.when.apply(dfds).done(this.proxy("update_map_all"));
  }

  , ".jump-to-control click" : function(el, ev) {
    var $item = this.element.find(".controls-list [content_id=" + el.data("content-id") + "]");
    var $content = $item.closest(".content");
    $item.find("a").click();
    $content.scrollTop(0).scrollTop($item.offset().top - $content.offset().top - ($content.height() - $item.height()) / 2);
  }

});



})(this, can.$);
