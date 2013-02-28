//= require can.jquery-all

can.Control("CMS.Controllers.SectionNotes", {
  defaults : {
    edit_view : "/assets/sections/edit_notes.mustache"
    , show_view : "/assets/sections/show_notes.mustache"
    , section_model : null
  }
}, {
  
  init : function() {
    if(!this.options.section_model) {
      this.options.section_model = this.element.closest("[data-model]").data("model");
    }
    this.draw_edit();
  }

  , update : function() {
    this.draw_edit();
  }

  , draw_edit : function() {
    var that = this;
    can.view(this.options.edit_view, this.options.section_model, function(frag) {
      that.element.html(frag)
      .find(".wysihtml5").cms_wysihtml5();
    });
  }

  , draw_notes : function(el, ev) {
    var that = this;
    if(ev && ev.stopPropagation)
      ev.stopPropagation();
    can.view(this.options.show_view, this.options.section_model, function(frag) {
      that.element.html(frag)
      .find(".wysihtml5").cms_wysihtml5();
    });
  }

  , ".wysihtml5-toolbar a click" : function(el, ev) {
    ev.stopPropagation();
  }

  , ".btn-add click" : function(el, ev) {
    ev.stopPropagation();
    this.options.section_model.attr("notes", this.element.find(".wysihtml5").data().wysihtml5.editor.composer.getValue());
    this.options.section_model.save().done(this.proxy("draw_notes")); 
  }

  , ".cancel-link click" : "draw_notes"

});