/*
 *= require jquery-min
 *= require jquery-ujs
 *= require jquery-ui
 *= require jquery.multiselect
 *= require jquery.multiselect.filter
 *= require jquery.manyselect
 */

// Put your application scripts here
jQuery(document).ready(function(){
  $('.collapsible .head').click(function() {
      $(this).toggleClass('toggle');
      $(this).next().toggle();
      return false;
  }).next().hide();
});

