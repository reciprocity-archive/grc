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
                var resp = new CMS.Models.Response();
                resp.attr({
                    request_id : $(event.target).closest("[data-filter-id]").data("filter-id")
                    , system_id : ui.item.value 
                });
                resp.save();
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

    $("#pbc-system-search").pbc_autocomplete();
});

})(this, can.$);