//= require can.jquery-all
//= require pbc/response
//= require pbc/system
//= require pbc/person

can.Control("CMS.Controllers.PBCModals", {
    defaults : {}
}, {
    ".add-document click" : function(el, ev) {
        this.selected_system_id = el.closest("[data-system-id]").data("system-id");
    }

    , ".documents-list li click" : function(el, ev) {
        var that = this
        , sys_id = this.selected_system_id;
        new CMS.Models.ObjectDocument({
            document_id : el.data("id")
            , system_id : this.selected_system_id
            , role : 'General Doc'
        })
        .save();
    } 

    , '.pbc-add-response > a modal:success' : function(el, e, data) {
      var $this = $(el)
        , $input = $this.closest('.pbc-add-response').find('.pbc-system-search')
        , resp = new CMS.Models.Response()
        ;
      resp.attr({
        request_id: $(e.target).closest("[data-filter-id]").data("filter-id")
        , system_id: data.id
      });
      resp.save();

      $input.val('');
      $this.closest('.collapse').collapse('hide');
    }

    , 'a.system-edit modal:success' : function(el, e, data) {
      var $this = $(el)
        , response_id = $this.closest('li[data-id]').data('id')
        , response = CMS.Models.Response.findInCacheById(response_id)
        , system_id = response.attr('system_id')
        , system = CMS.Models.System.findInCacheById(response.attr('system_id'))
        ;
      system.attr(data);
    }

    , ".delete-reponse click" : function(el, ev) {
      this.selected_response_id = el.closest("[data-id]").data("id");
    }

    , "a[data-method=delete] click" : function(el, ev) {
      var modal = el.closest(".modal")
      , options = modal.data("modal_form").options;

      el.addClass("disabled");

      CMS.Models.Response.findInCacheById(options.id).destroy()
        .then(function() {
          modal.modal_form("hide");
        });
      ev.preventDefault();
      ev.stopPropagation();
    }

    , '.pbc-control > a modal:select' : function(el, e, control_data) {
      var $this = $(el)
        , request_id = $this.closest('li[data-filter-id]').data('filter-id')
        ;

      $.post(
        '/requests/' + request_id,
        { _method: 'put'
        , 'request[control_id]': control_data.id
        }, function(data) {
          // FIXME: Brad, fix this if/when Requests are live-bound
          $this.closest('.pbc-control').find('.item').text(control_data.slug);
            //find this control
            var $ca = $(".pbc-control-assessments .pbc-ca-item[data-type=ControlAssessment][data-control-id=" + control_data.id + "]");

            // case 1: control exists -- no action needed
            if(!$ca.length) {
              // case 2: control does not exist
              $(".pbc-control-assessments").append(can.view("/pbc/control_assessment.mustache", control_data));
              $ca = $(".pbc-control-assessments .pbc-ca-item[data-control-id=" + control_data.id + "]");
            }
            el.closest(".pbc-requests > .main-item").detach().appendTo($ca.find(".pbc-requests"));
            $ca.find(".pbc-ca-title .expander, .pbc-ca-content").addClass("in")
            // sweep for newly empty control assessments and delete.
            $(".pbc-control-assessments .pbc-ca-item:not(:has(.main-item))").remove();
        });
    }

    , '.pbc-control-select > a modal:select' : function(el, e, control_data) {
      var $this = $(el)

      $this.closest('.pbc-control-select').find('.item').text(control_data.slug);
      $("#request_control_id").val(control_data.id)
    }
});
