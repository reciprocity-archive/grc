//= require control
//= require controls_controller
(function(namespace, $) {

$(function() {
//    new CMS.Controllers.Controls(document.body, { arity : 1, id : location.pathname.substring(location.pathname.lastIndexOf("/") + 1)});
    CMS.Controllers.Controls.Instances = { Control : new CMS.Controllers.Controls('#controls', { arity : 2 })};
});

})(this, jQuery);