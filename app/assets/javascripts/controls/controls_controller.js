//= require controls/control
//= require can.jquery-all
//= require controllers/filterable_controller

(function($) {

  CMS.Controllers.Filterable("CMS.Controllers.Controls", {
    //Static
    defaults: {
      arity: 2
      , list : "/assets/controls/list.mustache"
      , show : "/assets/controls/show.mustache"
      , model : CMS.Models.Control
      , id : null
      , spinner_while_filtering : true
      , spinner_style : {"position" : "absolute", "left" : 50, "top" : 50, "height": 150, "width": 150}
      //, list_model : CMS.Models.Control.List
    }
    , properties : []
  }, {
    setup : function() {
      typeof this._super === "function" && this._super.apply(this, arguments);
      this.options.observer = new can.Observe();
    }

    , init : function() {
      if(this.options.arity > 1) {
        this.fetch_list(this.options.id);
      } else {
        var el = this.element;

        if(this.options.id) {
          this.fetch_one(this.options.id);
        } else {
          this.draw_one(null)
        }
      }
    }
    , update : function(opt) {
      this._super(opt);
      if(this.options.arity === 1 && this.options.instance !== this.options.observer.model) {
        this.draw_one(this.options.instance);
        this.element.attr("oid", can.getObject("id", this.options.instance) || "");
      }
    }
    , fetch_list : function() {
      this.find_all_deferred = this.options.model.findAll({ id : this.options.id }, this.proxy("draw_list"));
    }
    , draw_list : function(list) {
      if(list) {
        this.list = list;
      } 
        this.options.observer.attr({list : this.list, show : this.options.show });
        var x = can.view(this.options.list, this.options.observer);
        this.element.html(x);
    }
    , fetch_one : function(id) {
      this.options.model.findOne({ id : (id || this.options.id) }, this.proxy("draw_one"));
    }
    , draw_one : function(control) {
      if(typeof this.options.observer.model !== "undefined") {
        this.options.observer.attr("model", control);
      } else {
        this.options.observer.attr("model", control);
        var v = can.view(this.options.show, this.options.observer);
        this.element.html(v);
      }
    }
    , ". update" : function(el, ev, data) {
      this.update(data);
    }
    , setSelected : function(obj) {
      if(this.options.arity > 1) {
        if(!obj instanceof this.options.model) {
          obj = $(this.list).filter(function() {
            var id = obj.id || obj;
            return id && this.id === id;
          }).first();
        }

        $(this.list).each(function() {
          this.attr("selected", $(obj)[0] === this );
        });
      }
    }
    , ".selector click" : function(el, ev) {
      this.setSelected(el.closest("[data-model]").data("model"));
    }

    //  Careful you don't try to hook up attribute events to can.Observes until
    //  they are actually craeted.  If you need to create one (e.g. on a per-instance basis), do it in setup()
    , "{observer} model" : function(el, ev, newVal, oldVal) {
      el.attr("oid", newVal ? newVal.id : "");
    }

    , "{observer.list} change" : function(el, ev, newVal, oldVal) {
      el.sort(this.natural_comparator);
    }

    , natural_comparator : function(a, b) {
      a = a.slug.toString();
      b = b.slug.toString();
      if(a===b) return 0;

      a = a.replace(/(?=\D\d)(.)|(?=\d\D)(.)/g, "$1$2|").split("|");
      b = b.replace(/(?=\D\d)(.)|(?=\d\D)(.)/g, "$1$2|").split("|")

      for(var i = 0; i < Math.max(a.length, b.length); i++) {
        if(+a[i] === +a[i] && +b[i] === +b[i]) {
          if(+a[i] < +b[i]) return -1;
          if(+b[i] < +a[i]) return 1;
        } else { 
          if(a[i] < b[i]) return -1;
          if(b[i] < a[i]) return 1;
        }
      }
      return 0;
    }

  });

})(can.$);
