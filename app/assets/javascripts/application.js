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

$(document).ajaxComplete(function(event, request){
  var flash = $.parseJSON(request.getResponseHeader('X-Flash-Messages'));
  if (!flash) return;
  if (flash.notice) { $('.flash > .notice').html(flash.notice); }
  else $('.flash > .notice').html('');
  if (flash.error) { $('.flash > .error').html(flash.error); }
  else $('.flash > .error').html('');
  if(flash.warning) { $('.flash > .warning').html(flash.error); }
  else $('.flash > .warning').html('');
});
