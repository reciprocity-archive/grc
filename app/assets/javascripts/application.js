/*
 *= require jquery-min
 *= require jquery-ujs
 *= require jquery-ui
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
