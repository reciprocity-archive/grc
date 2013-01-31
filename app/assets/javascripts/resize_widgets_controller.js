//= require can.jquery-all
//= require models/local_storage

(function(can, $){

can.Model.LocalStorage("CMS.Models.DisplayPrefs", {}, {});

can.Control("CMS.Controllers.ResizeWidgets", {
  defaults : {
    containers : []
    , columns_token : "columns"
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
  
  , init : function(el, newopts) {
    this._super && this._super(newopts);
    this.update(newopts);
  }

  , update : function(newopts) {
    var that = this;
    var opts = this.options;
    if(!(opts.model[opts.columns_token] instanceof can.Observe)) 
      opts.model.attr(opts.columns_token, new can.Observe(opts.model[opts.columns_token]));
    can.isArray(this.options.containers) || (this.options.containers = [this.options.containers]);
    can.each(this.options.containers, this.proxy('update_columns'));
    this.on();
  }

  , update_columns : function(container) {
    var $c = $(container)
    , $children = $c.children()
    , widths = this.getWidthsForSelector($c);

    for(var i = 1; i <= this.options.total_columns; i++) {
      $children.removeClass("span" + i);
    }
    if(!widths) {
      widths = this.divide_evenly($children.length);
      this.options.model.attr(this.options.columns_token).attr($c.attr("id"), widths);
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
    var parts = attr.split(".");
    if(parts.length > 1 && parts[0] === this.options.columns_token)
      this.update_columns($("#" + parts[1]));
  }

  , adjust_column : function(container, border_idx, adjustment) {
    var containers = this.options.model[this.options.columns_token];
    var col = this.getWidthsForSelector(container);
    var adjustment = this.normalizeAdjustment(col, border_idx, adjustment);

    if(!adjustment)
      return;

    col.attr(border_idx, col[border_idx] - adjustment);
    col.attr(border_idx - 1, col[border_idx - 1] + adjustment);
    this.options.model.save();
  }

  , normalizeAdjustment : function(col, border_idx, initial_adjustment) {
    var adjustment = initial_adjustment;

    if(border_idx < 1 || border_idx >= col.length) 
      return 0;

    //adjustment is +1, border_idx reduced by 1, adjustment should never be a higher number than border_idx width minus 1
    //adjustment is -1, border_idx-1 reduced by 1, adjustment should never be lower than negative( border_idx-1 width minus 1)

    adjustment = Math.min(adjustment, col[border_idx] - 1);
    adjustment = Math.max(adjustment, -col[border_idx - 1] + 1);

    return adjustment;
  }

  , getWidthsForSelector : function(sel) {
    return this.options.model.attr(this.options.columns_token).attr($(sel).attr("id"));
  }

  , " mousedown" : "startResize"

  , startResize : function(el, ev) {
    var that = this;
    var origTarget = ev.originalEvent ? ev.originalEvent.target : ev.target;
    can.each(this.options.containers, function(t) { 
      if ($(t).is(origTarget)) {
        var offset = Math.round((-$(t).offset().left + ev.pageX) / $(t).width() * that.options.total_columns);
        var widths = that.getWidthsForSelector(t).slice(0);
        var c_width = that.options.total_columns;
        while(c_width > offset) { //should be >=?
          c_width -= widths.pop();
        }
        //create the bar that shows where the new split will be
        $("<div>&nbsp;</div>")
        .addClass("width-selector-bar")
        .data("offset", offset)
        .data("start_offset", offset)
        .data("index", widths.length)
        .css({
          width: "5px"
          , height : $(t).height()
          , "background-color" : "black"
          , position : "absolute"
          , left : offset * $(t).width() / that.options.total_columns + $(t).offset().left
          , top : $(t).offset().top
        }).appendTo(t);
        //create an invisible drag target so we don't drag around a ghost of the bar
        $("<div>&nbsp;</div>")
        .attr("draggable", true)
        .addClass("width-selector-drag")
        .data("target", t)
        .css({
          left : ev.pageX
          , top : ev.pageY
          , position : "absolute"
        }).appendTo(t);
        return false;
      }
    });
  }

  , " mouseup" : "completeResize"
  , " dragend" : "completeResize"

  , completeResize : function(el, ev) {
    var $drag = $(".width-selector-drag");
    if($drag.length && $drag.data("target")) {
      var t = $drag.data("target")
      , $bar = $(".width-selector-bar")
      , offset = $bar.data("offset")
      , start_offset = $bar.data("start_offset")
      , index = $bar.data("index");

      this.adjust_column(t, index, offset - start_offset);
    }
    $(".width-selector-bar, .width-selector-drag").remove();
  }


  //, " dragstart" : function(el, ev)  { ev.preventDefault(); }

  , " dragover" : function(el, ev) {
    var $drag = $(".width-selector-drag");
    var $bar =  $(".width-selector-bar")
    if($drag.length && $drag.data("target")) {
      var t = $drag.data("target")
      , offset = Math.round((-$(t).offset().left + ev.pageX) / $(t).width() * this.options.total_columns)
      , adjustment = this.normalizeAdjustment(this.getWidthsForSelector(t), $bar.data("index"), offset - $bar.data("start_offset"));

      offset = $bar.data("start_offset") + adjustment;

      $bar
      .data("offset", offset)
      .css("left", offset * $(t).width() / this.options.total_columns + $(t).offset().left);
      ev.preventDefault();
    }
  }
});

})(this.can, this.can.$);