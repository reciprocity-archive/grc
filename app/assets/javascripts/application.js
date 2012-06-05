/*
 *= require jquery
 *= require jquery-ujs
 *= require jquery-ui
 *= require jquery.qtip
 *= require bootstrap
 *= require bootstrap/sticky-popover
 *= require bootstrap/modal-form
 *= require_self
 */

// Put your application scripts here
jQuery(document).ready(function() {
  $('.collapsible .head').click(function(e) {
      $(this).toggleClass('toggle');
      $(this).next().toggle();
      e.preventDefault();
  }).next().hide();
});

// Auto-clear search input on blur
jQuery(document).ready(function() {
  $('.clear-value').each(function() {
    var default_value = this.value;
    $(this).focus(function() {
      if(this.value == default_value) {
        this.value = '';
      }
    });
    $(this).blur(function() {
      if(this.value == '') {
        this.value = default_value;
      }
    });
  });
});

// Initialize tooltips
function update_tooltips(options)
{
  $('a[data-popover-href]').each(function() {
    var defaults = {
      delay: { show: 150, hide: 100 },
      placement: 'left',
      content: function(trigger) {
        var $trigger = $(trigger);

        var $el = $(new Spinner().spin().el);
        $el.css({
          width: '100px',
          height: '100px',
          left: '50px',
          top: '50px'
        });
        return $el[0];
      }
    };
    $(this).sticky_popover($.extend({}, defaults, options));
  });
}

jQuery(document).ready(function($) {
  update_tooltips({ placement: 'right' });
});
