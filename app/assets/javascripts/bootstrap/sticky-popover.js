!function ($) {

  "use strict"; // jshint ;_;


 /* STICKY_POPOVER PUBLIC CLASS DEFINITION
* =============================== */

  var StickyPopover = function ( element, options ) {
    this.init('sticky_popover', element, options)
  }


  /* NOTE: STICKY_POPOVER EXTENDS BOOTSTRAP-POPOVER.js and BOOTSTRAP-TOOLTIP.js
========================================== */

  StickyPopover.prototype = $.extend({}, $.fn.popover.Constructor.prototype, {

    constructor: StickyPopover

  , init: function(type, element, options) {
      $.fn.popover.Constructor.prototype.init.apply(this, arguments);

      // `displayState` is used to avoid duplicate calls to `show`
      //   (otherwise it flickers if `animation` is true
      this.displayState = this.displayState || 'hide';
    }
  , show: function(force) {
      // Overload `show` to listen for mouseovers on the popover div
      if (force || this.displayState !== 'show') {
        this.displayState = 'show';
        this.trigger_load();
        $.fn.popover.Constructor.prototype.show.apply(this);
        this.tip().
          on('mouseenter', $.proxy(this.tip_enter, this)).
          on('mouseleave', $.proxy(this.tip_leave, this));
      }
    }
  , hide: function() {
      if (this.displayState === 'show') {
        this.displayState = 'hide';
        $.fn.popover.Constructor.prototype.hide.apply(this);
      }
    }
  , trigger_load: function() {
      var self = this,
          href = this.$element.data('popover-href'),
          loaded = this.$element.data('popover-loaded');

      if (!href) return;

      if (!loaded) {
        $.get(href, function(data) {
	  var $data = $(data);
	  console.debug($data)
	  self.$element.attr('data-original-title', $data.filter('.popover-title').html());
          self.$element.attr('data-content', $data.filter('.popover-content').html());
          self.$element.data('popover-loaded', true);
          self.show(true);
        });
      }
    }
  , tip_enter: function(e) {
      // Handle `mouseenter` on the popover element
      // Must set 'e.currentTarget' or it looks for `data.stick_popover`
      //   in the wrong place
      e.currentTarget = this.$element[0];
      $.fn.popover.Constructor.prototype.enter.apply(this, arguments);
    }
  , tip_leave: function(e) {
      // Handle `mouseenter` on the popover element
      // Must set 'e.currentTarget' or it looks for `data.stick_popover`
      //   in the wrong place
      e.currentTarget = this.$element[0];
      $.fn.popover.Constructor.prototype.leave.apply(this, arguments);
    }
  })


 /* STICKY_POPOVER PLUGIN DEFINITION
* ======================= */

  $.fn.sticky_popover = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('sticky_popover')
        , options = typeof option == 'object' && option
      if (!data) $this.data('sticky_popover', (data = new StickyPopover(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.sticky_popover.Constructor = StickyPopover

  $.fn.sticky_popover.defaults = $.extend({} , $.fn.popover.defaults, {
  })

}(window.jQuery);

