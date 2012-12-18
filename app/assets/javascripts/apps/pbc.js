//= require can.jquery-all
//= require pbc/responses_controller
//= require pbc/system

(function(namespace, $) {
    
$.widget(
    "pbc.autocomplete"
    , $.ui.autocomplete
    , {
        options : {
            minLength: 1
            , source: CMS.Models.System.search
            , focus: function( event, ui ) {
                //$( "#project" ).val( ui.item.label );
                return false;
            }
            , select: function( event, ui ) {
                var $this = $(this)
                  , resp = new CMS.Models.Response();
                resp.attr({
                    request_id : $(event.target).closest("[data-filter-id]").data("filter-id")
                    , system_id : ui.item.value 
                });
                resp.
                  save().
                  then(function(){ $this.val(""); });
                return false;
            }
            , open: function() {
                $( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
            }
            , close: function() {
                $( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
            }
        }
        , _renderItem : function( ul, item ) {
            return $( "<li class='something'>" )
                .data( "item.autocomplete", item )
                .append( "<a>" + item.label + "</a>" )
                .appendTo( ul );
        }
    }
);
$.widget.bridge("pbc_autocomplete", $.pbc.autocomplete);

$(function() {
    $(document.body).on("click", ".pbc-responses-container", function(ev) {
        $(ev.currentTarget).find(".pbc-responses").cms_controllers_responses({id : $(ev.currentTarget).closest("[data-filter-id]").data("filter-id")});
    });

    $(".pbc-system-search").pbc_autocomplete();

    $('body').on('modal:success', '.pbc-add-response > a', function(e, data) {
      var $this = $(this)
        , resp = new CMS.Models.Response()
        ;
      resp.attr({
        request_id: $(e.target).closest("[data-filter-id]").data("filter-id")
        , system_id: data.id
      });
      resp.save();
    });

    $('body').on('modal:success', 'a.system-edit', function(e, data) {
      var $this = $(this)
        , response_id = $this.closest('li[data-id]').data('id')
        , response = CMS.Models.Response.findInCacheById(response_id)
        , system_id = response.attr('system_id')
        , system = CMS.Models.System.findInCacheById(response.attr('system_id'))
        ;
      system.attr(data);
    });

    $('body').on('modal:select', '.pbc-control > a', function(e, control_data) {
      var $this = $(this)
        , request_id = $this.closest('li[data-filter-id]').data('filter-id')
        ;

      $.post(
        '/requests/' + request_id,
        { _method: 'put'
        , 'request[control_id]': control_data.id
        }, function(data) {
          // FIXME: Brad, fix this if/when Requests are live-bound
          $this.closest('.pbc-control').find('.item').text(control_data.slug);
      });
    });
});

})(this, can.$);
