//= require can.jquery-all
//= require models/local_storage

(function(can, $){

can.Model.LocalStorage("CMS.Models.DisplayPrefs", {}, {});

can.Control("CMS.Controllers.ResizeWidgets", {
  defaults : {
    containers : []
    , total_columns : 12
  }
}, {

  setup : function(el, opts) {
    this._super && this._super.apply(this, arguments)
    var that = this;
    CMS.Models.DisplayPrefs.findAll().done(function(data) {
      var m = data[0] || new CMS.Models.DisplayPrefs();
      m.save();
      that.options.model = m;
      that.on();
    });
  }
  
  , init : function(el, opts) {
    this._super && this._super(opts)
    this.update(opts);
  }

  , update : function(newopts) {
    var that = this;
    can.isArray(this.options.containers) || (this.options.containers = [this.options.containers]);
    can.each(this.options.containers, this.proxy('update_columns'));
  }

  , update_columns : function(container) {
    var $c = $(container)
    , $children = $c.children()
    , widths = this.options.model.attr($c.attr("id"));

    for(var i = 1; i <= this.options.total_columns; i++) {
      $children.removeClass("span" + i);
    }
    if(!widths) {
      widths = this.divide_evenly($children.length);
      this.options.model.attr($c.attr("id"), widths);
    }
    $children.each(function(i, child) {
      $(child).addClass("span" + widths[i]);
    });
  }

  , divide_evenly : function(n) {
    var tc = this.options.total_columns;
    var ret = [];
    while(ret.length < n) {
      ret.push(Math.floor(tc / n));
    }
    if(n % 2) {
      //odd case
      ret[Math.floor(n / 2)] += tc % (ret[0] * ret.length);
    } else {
      //even case 
      ret[n / 2 - 1] += Math.floor(tc % (ret[0] * ret.length) / 2);
      ret[n / 2] += Math.ceil(tc % (ret[0] * ret.length) / 2);
    }

    return ret;
  }

  , "{model} change" : function(el, ev, attr, how, newVal, oldVal) {
    this.update_columns($("#" + attr));
  }

});

})(this.can, this.can.$);