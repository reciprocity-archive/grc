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
    , page_token : null
    , minimum_widget_height : 100
    , resizable_selector : "section[id]"
    , magic_content_height_offset : 17 //10px padding of the list inside the section + 7px height of resize handle
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

    //late binding page token because the body properties are not available when the class is created
    this.options.page_token || (this.options.page_token = window.getPageToken());

    //set up dragging the bottom border to resize in jQUI
    $(this.element)
    .find(this.options.resizable_selector)
    .filter(function() {
      var cs = that.options.model.getCollapsed(that.options.page_token, $(this).attr("id"));
      return cs == null ? true : !cs;
    })
    .each(function() {
      var extra_ht = 0;
      function add_height(index, el) {
        extra_ht += $(el).height();        
      }

      $(this).children().not(".content").each(add_height);
      if($(".content .tab-content", this).not(".tabs-left .tab-content").length) {
        $(".content .tab-content", this).siblings().each(add_height);
      }

      $(this)
      .resizable({
        handles : "s"
        , minHeight : that.options.minimum_widget_height + extra_ht
        , autoHide : false
        , alsoResize : $(this).find(".content")
      });
    });

    this.update(newopts);
  }

  , update : function(newopts) {
    var that = this
    , opts = this.options;

    this.update_columns();
    this.update_heights();
    this.on();
  }

  , update_columns : function() {    
    var $c = $(this.element)
    , $children = $c.children().not(".width-selector-bar, .width-selector-drag")
    , widths = this.getWidthsForSelector($c)
    , widths
    , total_width = 0
    , that = this;


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
      this.options.model.setColumnWidths(this.options.page_token, $c.attr("id"), widths);
    }  


    for(i = 1; i <= this.options.total_columns; i++) {
      $children.removeClass("span" + i);
    }

    $children.each(function(i, child) {
      $(child).addClass("span" + widths[i]);

      $(child).find(that.options.resizable_selector).each(function(i, gc) {
        that.check_horizontal_tab_sheet(gc);
      });
    });
  }

  , " section_created" : "update_heights"

  , update_heights : function() {
    var model = this.options.model
    , page_heights = model.getWidgetHeights(this.options.page_token)
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
          $(grandchild).css("height", "").find(".widget-showhide > a").showhide("hide")
        } else {
          if(page_heights.attr($(grandchild).attr("id")) != null) {
            var sh = page_heights.attr($(grandchild).attr("id"));
            that.set_widget_height(grandchild, sh);
          } else {
            // missing a height.  redistribute evenly but don't increase the size of anythng.
            var visible_ht = Math.floor($(window).height() - $(child).offset().top) - 10
            , split_ht = visible_ht / $gcs.length
            , col_ht = $(child).height();
            $shrink_these = $gcs.filter(function() { return $(this).height() > split_ht });
            $shrink_these.each(function(i, grandchild) {
              var $gc = $(grandchild);
              var this_split_ht = split_ht - parseInt($gc.css("margin-top")) - (parseInt($gc.prev($gcs).css("margin-bottom")) || 0);
              that.set_widget_height($gc, content_height_func.apply(grandchild));
              model.setWidgetHeight(that.options.page_token, $gc.attr("id"), this_split_ht);
              col_ht = $(child).height() + $(child).offset().top;
            });
            $gcs.not($shrink_these).each(function(i, grandchild) {
              var $gc = $(grandchild);
              if(!page_heights.attr($gc.attr("id"))) {
                model.setWidgetHeight(that.options.page_token, $gc.attr("id"), $gc.height());
              }
            });
            dirty = true;
            return false;
          }
        }
      });
    });
    if(dirty) {
      model.save();
      $c.find("section[id]").each(function() { that.ensure_minimum(this); });
    }
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
    if(parts.length > 1 && parts[0] === window.location.pathname && parts[2] === $(this.element).attr("id")) {
      this.update_columns();
      this.options.model.save();
    }
    if(parts.length > 1 
      && parts[0] === window.location.pathname 
      && parts[1] === this.options.heights_token 
      && $(this.element).has("#" + parts[2]).length) {
      this.update_heights();
      this.options.model.save();
    }
  }

  , adjust_column : function(container, border_idx, adjustment) {
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
    return this.options.model.getColumnWidths(this.options.page_token, $(sel).attr("id")) || [];
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
    if (($t.is(origTarget) || $(origTarget).is(".width-selector-bar, .width-selector-drag"))
        && $(".width-selector-bar", $t).length) {
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
      .appendTo($t);
    }
  }


  , " mouseover" : "showGhostResizer"
  , " mousemove" : "showGhostResizer"
  , "{window} resize" : function(el, ev) {
    var that = this;
    this.showGhostResizer(this.element, ev);
    this.element.find(this.options.resizable_selector).filter(":has(.content:visible)").each(function(i, el) {
      that.ensure_minimum(el);
      that.check_horizontal_tab_sheet(el);
    });
  }

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
      var that = this
      , t = this.element
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
      t.find(this.options.resizable_selector).each(function(i, section) {
        that.ensure_minimum(section);
        that.check_horizontal_tab_sheet(section);
      });
    }

  }

  , removeResizer : function(el, ev) {    
    $(".width-selector-bar", this.element).remove();
  }

  , " mouseup" : "completeResize"
  , " dragend" : "completeResize"

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
    this.ensure_minimum($(ui.element).closest(this.options.resizable_selector), ht);
  }

  , "{resizable_selector} min_size" : function(el, ev) {
    this.ensure_minimum(el);
  }

  , ensure_minimum : function(el, ht) {
    var $el = $(el);
    $el.css("width", "").find(".content").css("width", ""); //bizarre jQUI behavior fix
    if(!$el.find(".widget-showhide .active").length) {
      return; //don't resize widgets that are collapsed
    }

    if(!ht) {
      ht = $el.height();
    }

    var min_ht = this.options.minimum_widget_height;
    function add_height(index, elt) {
      min_ht += $(elt).height();
    }

    $el.children().not(".content, .ui-resizable-handle").each(add_height);
    if($(".content .tab-content", el).not(".tabs-left .tab-content").length) {
      $(".content .tab-content", el).siblings().each(add_height);
    }

    if($el.is(":not(.ui-resizable)") || $el.resizable("option").minHeight !== min_ht) {
      if($el.is(".ui-resizable")) {
        $el.resizable("destroy");
      }
      $el.resizable({
        handles : "s"
        , minHeight : min_ht
        , autoHide : false
        , alsoResize : $el.find(".content")
      });
    }
    if(ht < min_ht) {
      ht = min_ht;
    }
    this.set_widget_height(el, ht);
    this.options.model.setWidgetHeight(this.options.page_token, $el.attr("id"), ht);
  }

  // lower-level function than ensure_minimum
  // sets the height of the widget and its associated content pane
  , set_widget_height : function(el, ht) {
    var $el = $(el);
    $el.css("height", ht);

    var content_ht = ht;
    var min_content_ht = this.options.minimum_widget_height;
    function add_height_outside(index, elt) {
      content_ht -= $(elt).height();
    }
    function add_height_inside(index, elt) {
      min_content_ht += $(elt).height();
    }

    $el.children().not(".content, .ui-resizable-handle").each(add_height_outside);
    if($(".content .tab-content", el).not(".tabs-left .tab-content").length) {
      $(".content .tab-content", el).siblings().each(add_height_inside);
    }

    $el.find(".content:first").css("height", Math.max(min_content_ht, content_ht) - this.options.magic_content_height_offset);
  }

  , check_horizontal_tab_sheet : function(el) {
    var $el = $(el);
    $el = $el.is(".nav-tabs:not(.tabs-left > *)") ? $el.first() : $el.find(".nav-tabs:not(.tabs-left > *):first");

    if(!$el.length)
      return;

    $el.find("a:data(text)").each(function(i, tablink) {
      var $tab = $(tablink);
      $tab.append($tab.data("text")).tooltip("disable").removeData("text");
    });

    var fullwidth = can.reduce($el.children(), function(total, t) {
      return total + $(t).width();
    }, 0);

    if(fullwidth > $el.parent().width()) {
      //this is where we need to shrink
      $el.find("a:not(:data(text))").each(function(i, tablink) {
        var $tab = $(tablink)
        , oldtmpl = $tab.attr("data-template");
        $tab
        .data("text", $tab.text())
        .attr("data-original-title", $tab.text())
        .removeAttr("data-template")
        .tooltip({delay : {show : 500, hide : 0}})
        .tooltip("enable")
        .html($tab.children())
        .attr("data-template", oldtmpl);
      });
    }
  }


  , "section[id] > header dblclick" : function(el, ev) {
    if(!$(ev.target).closest(".widget-showhide").length) {
      $(el).find(".widget-showhide a").click();
    }
  }

  , ".widget-showhide click" : function(el, ev) {
    var that = this;
    //animation hasn't completed yet, so collapse state is inverse of whether it's actually collapsed right now.
    var $section = el.closest(this.options.resizable_selector);
    var collapse = $section.find(".content").is(":visible");
    console.log("collapse is ", collapse)
      collapse && $section.css("height", "").find(".content").css("height", "");
      if(collapse && $section.is(".ui-resizable")) {
        $section.resizable("destroy");
      } else if(!collapse) {
        setTimeout(function() { 
          that.ensure_minimum($section, that.options.model.getWidgetHeight(that.options.page_token, $section.attr("id")));
        }, 1);
      }
      that.options.model.setCollapsed(that.options.page_token, $section.attr("id"), collapse);
  }

});

})(this.can, this.can.$);