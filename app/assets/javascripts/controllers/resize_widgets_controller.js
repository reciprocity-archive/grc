//= require can.jquery-all
//= require models/local_storage

(function(can, $){

can.Model.LocalStorage("CMS.Models.DisplayPrefs", {}, {});

can.Control("CMS.Controllers.ResizeWidgets", {
  defaults : {
    containers : []
    , columns_token : "columns"
    , total_columns : 12
    , default_layout : null
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
    var that = this
    , opts = this.options
    , widths
    , total_width = 0;

    if(!(opts.model[opts.columns_token] instanceof can.Observe)) 
      opts.model.attr(opts.columns_token, new can.Observe(opts.model[opts.columns_token]));
    widths = this.getWidthsForSelector($(this.element)) || [];

    for(var i = 0; i < widths.length; i++) {
      total_width += widths[i];
    }
    if(total_width != this.options.total_columns) {
      widths = this.sensible_default($(this.element).children().not(".width-selector-bar, .width-selector-drag").length);
      this.options.model.attr(this.options.columns_token).attr($(this.element).attr("id"), widths);
      this.options.model.save();
    }
    this.update_columns();
    this.on();
  }

  , update_columns : function() {
    var $c = $(this.element)
    , $children = $c.children().not(".width-selector-bar, .width-selector-drag")
    , widths = this.getWidthsForSelector($c);


    for(i = 1; i <= this.options.total_columns; i++) {
      $children.removeClass("span" + i);
    }
    if(!widths || $children.length != widths.length) {
      widths = this.sensible_default($children.length);
      this.options.model.attr(this.options.columns_token).attr($c.attr("id"), widths);
      this.options.model.save();
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

  , sensible_default : function(n) {
    switch(n) {
      case 3:
      return [3, 6, 3];
      case 4:
      return [2, 4, 4, 2];
      default:
      return this.divide_evenly(n);
    }

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

  , getLeftOffset : function(pageX) {
    var $t = $(this.element);
    return Math.round((pageX - $t.offset().left - parseInt($t.css("padding-left"))) / $t.width() * this.options.total_columns);
  }

  , getLeftOffsetAsPixels : function(offset) {
    var $t = $(this.element);
    return offset * $t.width() / this.options.total_columns + $t.offset().left + parseInt($t.css("padding-left")) - $(window).scrollLeft();
  }

  , " mousedown" : "startResize"

  , startResize : function(el, ev) {
    var that = this;
    var origTarget = ev.originalEvent ? ev.originalEvent.target : ev.target;
    var $t = $(this.element);
    if ($t.is(origTarget)) {
      var offset = this.getLeftOffset(ev.pageX);
      var widths = that.getWidthsForSelector($t).slice(0);
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
        , height : $t.height()
        , "background-color" : "black"
        , position : "fixed"
        , left : this.getLeftOffsetAsPixels(offset)
        , top : $t.offset().top - $(window).scrollTop()
      }).appendTo($t);
      //create an invisible drag target so we don't drag around a ghost of the bar
      $("<div>&nbsp;</div>")
      .attr("draggable", true)
      .addClass("width-selector-drag")
      .css({
        left : ev.pageX - $(window).scrollLeft() - 1
        , top : ev.pageY - $(window).scrollTop() - 1
        , position : "fixed"
        , width : "3px"
        , height : "3px"
        , cursor : "e-resize w-resize"
      })
      //.bind("mouseup dragend", this.proxy('completeResize', this.element))
      //.bind("dragover", this.proxy('recalculate', this.element))
      .appendTo($t);
    }
  }


  , completeResize : function(el, ev) {
    var $drag = $(".width-selector-drag");
    if($drag.length) {
      var t = this.element
      , $bar = $(".width-selector-bar")
      , offset = $bar.data("offset")
      , start_offset = $bar.data("start_offset")
      , index = $bar.data("index");

      this.adjust_column(t, index, offset - start_offset);
    }
    $(".width-selector-bar, .width-selector-drag").remove();
  }

  , " mouseup" : "completeResize"
  , " dragend" : "completeResize"

  //, " dragstart" : function(el, ev)  { ev.preventDefault(); }

  , " dragover" : "recalculateDrag"
  , recalculateDrag : function(el, ev) {
    var $drag = $(this.element).find(".width-selector-drag");
    var $bar =  $(this.element).find(".width-selector-bar")
    if($drag.length) {
      var $t = $(this.element)
      , offset = this.getLeftOffset(ev.pageX)
      , adjustment = this.normalizeAdjustment(this.getWidthsForSelector($t), $bar.data("index"), offset - $bar.data("start_offset"));

      offset = $bar.data("start_offset") + adjustment;

      $bar
      .data("offset", offset)
      .css("left", this.getLeftOffsetAsPixels(offset));
      ev.preventDefault();
    }
  }

});

})(this.can, this.can.$);