//require can.jquery-all

(function(can, $) {
  function with_params(href, params) {
    if (href.charAt(href.length - 1) === '?')
      return href + params;
    else if (href.indexOf('?') > 0)
      return href + '&' + params;
    else
      return href + '?' + params;
  }

can.Control("CMS.Controllers.QuickSearch", {
  defaults : {}
}, {

  setup : function(el, opts) {
    this._super && this._super.apply(this, arguments);
    if(!opts.observer) {
      opts.observer = new can.Observe();
    }
  }

  , init : function(opts) {

  }

  , "{observer} value" : function(el, ev, newval) {

    var $tabs = $(this.element).find('ul.nav-tabs:first > li > a')
      , $tab = $tabs.filter('ul.nav-tabs > li.active > a')
      //, href = with_params($tab.data('tab-href'), $.param({ s: newval }));

    $tabs.each(function() {
      var href = $(this).data("tab-href");
      href = href.split("?");
      var qparams = can.deparam(href[1])
      qparams["s"] = newval;
      href[1] = can.param(qparams);
      $(this).data("tab-href", href.join("?"));
    })
    $tabs.data("tab-loaded", false)
    $tab.trigger('show', $tab.data("tab-href"));
    $tab.trigger('kill-all-popovers');
  }

  , ".tabbable loaded" : function(el, ev) {
    $(el).scrollTop(0);
  }
});

})(this.can, this.can.$);