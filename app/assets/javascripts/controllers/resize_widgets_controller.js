//= require can.jquery-all
//= require models/local_storage
//= require models/display_prefs

(function(can, $){

can.Control("CMS.Controllers.ResizeWidgets", {
  defaults : {
    columns_token : "columns"
    , heights_token : "heights"
    , total_columns : 12
    , default_layout : null
    , page_token : window.location.pathname.substring(1, (window.location.pathname + "/").indexOf("/", 1))
    , minimum_widget_height : 100
    , content_selector : ".content, .tab-content"
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
    var that = this;

    //set up dragging the bottom border to resize in jQUI
    $(this.element)
    .find("section[id]")
    .filter(function() {
      var cs = that.options.model.getCollapsed(that.options.page_token, $(this).attr("id"));
      return cs == null ? true : !cs;
    })
    .each(function() {
      $(this)
      .find(that.options.content_selector).first()
      .resizable({
        handles : "s"
        , minHeight : that.options.minimum_widget_height
        , alsoResize : this
        , autoHide : false
      });
    });

    this.update(newopts);
  }

  , update : function(newopts) {
    var that = this
    , opts = this.options

    if(!(opts.model[opts.columns_token] instanceof can.Observe)) 
      opts.model.attr(opts.columns_token, new can.Observe(opts.model[opts.columns_token]));
    if(!(opts.model[opts.heights_token] instanceof can.Observe)) 
      opts.model.attr(opts.heights_token, new can.Observe(opts.model[opts.heights_token]));
    if(!(opts.model[opts.heights_token][opts.page_token] instanceof can.Observe)) 
      opts.model.attr(opts.heights_token).attr(opts.page_token, new can.Observe(opts.model[opts.heights_token][opts.page_token]));


    this.update_columns();
    this.update_heights();
    this.on();
  }

  , update_columns : function() {    
    var $c = $(this.element)
    , $children = $c.children().not(".width-selector-bar, .width-selector-drag")
    , widths = this.getWidthsForSelector($c)
    , widths
    , total_width = 0;


    widths = this.getWidthsForSelector($(this.element)) || [];

    for(var i = 0; i < widths.length; i++) {
      total_width += widths[i];
    }
    if(total_width != this.options.total_columns) {
      var scraped_cols = [];
      var scraped_col_total = 0;
      $children.each(function(i, child) {
        var classes = $(child).attr("class").split(" ");
        can.each(classes, function(_class) {
          var c;
          if(c = /^span(\d+)$/.exec(_class)) {
            scraped_cols.push(+c[1]);
            scraped_col_total += (+c[1]);
          }
        });
      });
    }

    if(!widths || $children.length != widths.length) {
      if(scraped_col_total === this.options.total_columns) {
        widths = scraped_cols;
      } else {
        widths = this.sensible_default($children.length);
      }
      this.options.model.attr(this.options.columns_token).attr($c.attr("id"), widths);
      this.options.model.save();
    }  


    for(i = 1; i <= this.options.total_columns; i++) {
      $children.removeClass("span" + i);
    }

    $children.each(function(i, child) {
      $(child).addClass("span" + widths[i]);
    });
  }

  , " section_created" : "update_heights"

  , update_heights : function() {
    var model = this.options.model
    , heights = model.attr(this.options.heights_token)
    , page_heights = heights.attr(this.options.page_token)
    , that = this
    , dirty = false
    , $c = $(this.element).children(".widget-area")
    , content_height_func = function() {
      var ch = $(this).parent().height() - parseInt($(this).parent().css("margin-bottom"));
      ch = Math.max(ch, that.options.minimum_widget_height)
      $(this).siblings().each(function() {
        ch -= $(this).height();
      });
      return ch;
    };

    if(!$c.length) {
      $c = $(this.element).children();
    }

    $c.each(function(i, child) {
      var $gcs = $(child).find("section[id]");
      $gcs.each(function(j, grandchild) {
        if(that.options.model.getCollapsed(that.options.page_token, $(grandchild).attr("id"))) {
          $(grandchild).find(that.options.content_selector).first().css("height", "").find(".widget-showhide > a").showhide("hide");
        } else {
          if(page_heights.attr($(grandchild).attr("id"))) {
            var sh = page_heights.attr($(grandchild).attr("id"));
            $(grandchild).find(that.options.content_selector).first().css("height", sh);

          } else {
            // missing a height.  redistribute evenly but don't increase the size of anythng.
            var visible_ht = Math.floor($(window).height() - $(child).offset().top) - 10
            , split_ht = visible_ht / $gcs.length
            , col_ht = $(child).height();
            $shrink_these = $gcs.filter(function() { return $(this).height() > split_ht });
            $shrink_these.each(function(i, grandchild) {
              var $gc = $(grandchild).find(that.options.content_selector).first();
              var this_split_ht = split_ht - parseInt($gc.css("margin-top")) - (parseInt($gc.prev($gcs).css("margin-bottom")) || 0);
              $gc.attr("height", content_height_func);
              page_heights.attr($gc.attr("id"), this_split_ht);
              col_ht = $(child).height() + $(child).offset().top;
            });
            $gcs.not($shrink_these).each(function(i, grandchild) {
              var $gc = $(grandchild);
              if(!page_heights.attr($gc.attr("id"))) {
                page_heights.attr($gc.attr("id"), $gc.height());
              }
            });
            dirty = true;
            return false;
          }
        }
      });
    });
    if(dirty)
     model.save();

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
      case 2:
      return [5, 7];
      case 3:
      return [3, 6, 3];
      default:
      return this.divide_evenly(n);
    }

  }

  , "{model} change" : function(el, ev, attr, how, newVal, oldVal) {
    var parts = attr.split(".");
    if(parts.length > 1 && parts[0] === this.options.columns_token && parts[1] === $(this.element).attr("id")) {
      this.update_columns();
      this.options.model.save();
    }
    if(parts.length > 1 && parts[0] === this.options.heights_token && $(this.element).has("#" + parts[1])) {
      this.update_heights();
      this.options.model.save();
    }
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

    adjustment = Math.min(adjustment, col[border_idx] - 2);
    adjustment = Math.max(adjustment, -col[border_idx - 1] + 2);

    return adjustment;
  }

  , getWidthsForSelector : function(sel) {
    return this.options.model.attr(this.options.columns_token).attr($(sel).attr("id"));
  }

  , getLeftOffset : function(pageX) {
    var pct_offset = -.025641;
    var $t = $(this.element)
      , margin = parseInt($t.children('[class*=span]:last').css('margin-left'));
    return Math.round((pageX + 3 + margin / 2 - $t.offset().left) * this.options.total_columns / (1 - pct_offset) / $t.width());
  }

  , getLeftOffsetAsPixels : function(offset) {
    var pct_offset = -.025641;
    var $t = $(this.element)
      , margin = parseInt($t.children('[class*=span]:last').css('margin-left'));
    return $t.width() * (offset / this.options.total_columns * (1 - pct_offset)) + $t.offset().left - margin / 2 - 3;
  }

  , " mousedown" : "startResize"

  , startResize : function(el, ev) {
    var that = this;
    var origTarget = ev.originalEvent ? ev.originalEvent.target : ev.target;
    var $t = $(this.element);
    if ($t.is(origTarget) || $(origTarget).is(".width-selector-bar, .width-selector-drag")) {
      var offset = this.getLeftOffset(ev.pageX);
      var widths = that.getWidthsForSelector($t).slice(0);
      var c_width = that.options.total_columns;
      while(c_width > offset) { //should be >=?
        c_width -= widths.pop();
      }
      //create the bar that shows where the new split will be
      var $bar = $(".width-selector-bar", $t);
      if(!$bar.length) {
        $bar = $("<div>&nbsp;</div>")
        .addClass("width-selector-bar")
        .data("offset", offset)
        .data("start_offset", offset)
        .data("index", widths.length)
        .css({
          width: "5px"
          , height : $t.height()
          , position : "fixed"
          , left : this.getLeftOffsetAsPixels(offset)
          , top : $t.offset().top - $(window).scrollTop()
        }).appendTo($t);
      }
      $bar.css("opacity", "1.0");
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
        , cursor : "move"
      })
      //.bind("mouseup dragend", this.proxy('completeResize', this.element))
      //.bind("dragover", this.proxy('recalculate', this.element))
      .appendTo($t);
    }
  }


  , " mouseover" : "showGhostResizer"
  , " mousemove" : "showGhostResizer"
  , "{window} resize" : "showGhostResizer"

  , showGhostResizer : function(el, ev) {
    var that = this;
    var origTarget = ev.originalEvent ? ev.originalEvent.target : ev.target;
    var $t = $(this.element);
    if(!$t.is(origTarget) && !$(origTarget).is(".width-selector-bar") && !$(".width-selector-drag", $t).length ) {
      this.removeResizer();
      return;
    }
    var offset = this.getLeftOffset(ev.pageX);
    var widths = this.getWidthsForSelector($t).slice(0);
    var acc = 0;
    for(var i = 0; i < widths.length && acc !== offset; i++) {
      acc += widths[i];
      if(acc > offset) { //counted past our current offset. we're not near a gutter.
        this.removeResizer();
        return;
      }
    }

    var gutterX = this.getLeftOffsetAsPixels(offset);
    var gutterWidth = Math.max.apply(Math, $t.children().map(function() { return parseInt($(this).css("margin-left")); }).get());

    if (!$(".width-selector-bar, .width-selector-drag").length
      && Math.abs(ev.pageX - gutterX) < gutterWidth / 2) {
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
        , position : "fixed"
        , left : gutterX
        , top : $t.offset().top - $(window).scrollTop()
        , opacity : "0.5"
      }).appendTo($t);
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
      $(".width-selector-drag", t).remove();
      $(".width-selector-bar", t).css("opacity", "0.5")
      if(!$(document.elementFromPoint(ev.pageX, ev.pageY)).is($(t).add(".width-selector-bar"))) {
        this.removeResizer();
      }
      can.each(t.find("section[id]"), this.proxy("ensure_minimum"));
    }

  }

  , removeResizer : function(el, ev) {    
    $(".width-selector-bar", this.element).remove();
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

  , " resizestop" : function(el, ev, ui) {
    var ht = $(ui.element).height();
    this.ensure_minimum($(ui.element).closest("section[id]"), ht);

  }

  , ensure_minimum : function(el, ht) {
    $(el).css("width", ""); //resize sometimes sets width for no reason
    if(!ht) {
      ht = $(el).find(this.options.content_selector).first().height();
    }

    if(ht < this.options.minimum_widget_height) {
      ht = this.options.minimum_widget_height;
      $(el).find(this.options.content_selector).first().css("height", ht);
    }

    this.options.model
    .attr(this.options.heights_token)
    .attr(this.options.page_token)
    .attr($(el).attr("id"), ht);
  }

  , ".widget-showhide click" : function(el, ev) {
    var that = this;
    //animation hasn't completed yet, so collapse state is inverse of whether it's actually collapsed right now.
    var $section = el.closest("section[id]");
    var collapse = $section.find(that.options.content_selector).first().is(":visible");
    CMS.Models.DisplayPrefs.findAll().done(function(d) { 
      collapse ? $section.css("height", "") : $section.css("height", d[0].getWidgetHeight(that.options.page_token, $section.attr("id")))
      $section
      .find(that.options.content_selector)
      .first()
      .resizable(collapse ? "destroy" : {
        handles : "s"
        , minHeight : that.options.minimum_widget_height
        , alsoResize : $section
        , autoHide : false
      });

      d[0].setCollapsed(that.options.page_token, $section.attr("id"), collapse);
    });
  }

});

})(this.can, this.can.$);