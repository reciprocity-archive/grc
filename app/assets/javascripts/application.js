/*
 *= require jquery-min
 *= require jquery-ujs
 *= require jquery-ui
 *= require jquery.qtip
 */

// Put your application scripts here
jQuery(document).ready(function() {
  $('.collapsible .head').click(function() {
      $(this).toggleClass('toggle');
      $(this).next().toggle();
      return false;
  }).next().hide();
});


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

function update_tooltips()
{
  jQuery(document).ready(function() {
    $('.item a[data-tooltip]').each(function () {
      $(this).qtip({
        content: {
          text: 'Loading...',
          ajax: { url: $(this).attr('data-tooltip')},
        },
        show: { target: $(this).parent(), solo: true },
        hide: { target: $(this).parent(), delay: 50 },
        position: { target: $(this).parent(), my: 'center', at: 'center' },
      });
    });
  });
}
