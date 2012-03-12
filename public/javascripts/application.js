// Put your application scripts here
jQuery(document).ready(function(){
  $('.collapsible .head').click(function() {
      $(this).toggleClass('toggle');
      $(this).next().toggle();
      return false;
  }).next().hide();
});

