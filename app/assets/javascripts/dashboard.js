/*
 *= require jquery-min
 *= require jquery-ui
 *= require_self
 */

jQuery(function($) {
  $('.box .tabbed').tabs();
});

jQuery(function($) {
  $('.quick-search').bind('change', function(e) {
    var $this = $(this),
        val = $this.val(),
        val_regex = new RegExp(val, 'i');

    $this.closest('.box').find('ul.items').each(function(i) {
      var $list = $(this);

      $list.find('> li').each(function(i) {
        if (val_regex.test($(this).text()))
          $(this).show();
        else
          $(this).hide();
      });
    });
  });
});

jQuery(function($) {
  $('ul.slugtree .expander').bind('click', function(e) {
    $(this).closest('li').find('> .content').toggle();
  });

  $('li.create-control a').bind('click', function(e) {
    console.debug(this, $(this).siblings('.dialog'));
    $(this).siblings('.dialog').dialog({
      title: "Create new control",
      height: 400,
      width: 400
    });
    e.preventDefault();
  });

  $('li.create-program a').bind('click', function(e) {
    console.debug(this, $(this).siblings('.dialog'));
    $(this).siblings('.dialog').dialog({
      title: "Create new program",
      height: 400,
      width: 400
    });
    e.preventDefault();
  });
})

