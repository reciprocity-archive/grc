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
  }  
}


can.Control("CMS.Controllers.Mapping", {
	//static
	cache : {}
}, {
  init : function() {
    this.updateButtons();
  }

	, "#rmap, #cmap click" : function(el, ev) {

    var section = $("#selected_sections").control(namespace.CMS.Controllers.Sections).options.instance;
    var rcontrol = $("#selected_rcontrol").control(namespace.CMS.Controllers.Controls).options.instance;
    var ccontrol = $("#selected_ccontrol").control(namespace.CMS.Controllers.Controls).options.instance;

    if(el.is($("#cmap"))) {
      section = null;
    }
    this[el.is(".unmapbtn") ? "unmap" : "map"](section, rcontrol, ccontrol); 
  }  

  , unmap : function() { mapunmap(true).apply(this, arguments); }
  , map : function() { mapunmap(false).apply(this, arguments); }

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
              runmap || (runmap = section && ccontrol ? $(section.linked_controls).filter(function() { return this.id === ccontrol.id}).length : false);
          var cunmap = rcontrol && ccontrol ? $(rcontrol.implementing_controls).filter(function() { return this.id === ccontrol.id}).length : false;

          rmap_text.text(runmap ? 'Unmap' : 'Map section to control')
          rmap[runmap ? 'addClass' : "removeClass"]("unmapbtn");
          cmap_text.text(cunmap ? 'Unmap' : 'Map control to control')
          cmap[cunmap ? 'addClass' : "removeClass"]("unmapbtn");
    }
  }
    , ".clearselection click" : function(el, ev) {
      this.updateButtons();
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

});

})(this, can.$);
