//= require can.jquery-all
//= require pbc/responses_controller
//= require pbc/modals_controller
//= require pbc/system

(function(namespace, $) {

    if(namespace.location.pathname.indexOf("/pbc_lists") < 0 && namespace.location.pathname.indexOf("/cycles") < 0)
        return;

function escapeHTML(s) {
  if (typeof(s)=='string') {
    s = s
      .replace(/'/g,'&#39;')
      .replace(/\"/g,'&quot;')
      .replace(/</g,'&lt;')
      .replace(/>/g,'&gt;');
  }
  return s;
}

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
                $this.trigger("systemOrProcessSelected", ui.item);
                $this.val('');
                return false;
            }
            , open: function() {
                $( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
            }
            , close: function() {
                $( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
            }
        }
        , _create: function() {
          //extend autocomplete so if you type something in and hit enter, it selects the first thing in the list.
          this._super.apply(this, arguments);

          function click_first() {
            var data = $(this).data();
            for(var i in data) {
              if(/^pbcAutocomplete/.test(i)) {
                var ac = data[i];
                if(!ac.selectedItem) {
                  setTimeout(function() {
                    ac.menu.element.children().first().click();
                  }, ac.options.delay || 100);
                }
                break;
              }
            }
          }

          this.element
          .keydown(function(ev) {
            if(ev.which === 13) {
              click_first.call(this);
            }
          })
          .next(".submit-btn")
          .click(click_first);
        }
        , _renderItem : function( ul, item ) {
            return $( "<li class='something'>" )
                .data( "item.autocomplete", item )
                .append( "<a>"+ escapeHTML(item.label) + "</a>" )
                .appendTo( ul );
        }
    }
);
$.widget.bridge("pbc_autocomplete", $.pbc.autocomplete);

$.widget(
  "pbc.autocomplete_people"
  , $.pbc.autocomplete
  , { options : {
      source : CMS.Models.Person.search
      , select :  function(event, ui) {
        $(event.target).trigger("personSelected", ui.item);
        $(this).data("pbcAutocomplete_people")._value("");
        return false;
      }
      , search : function(event) {

      }
      , response : function(event, data, ui) {
        if(!data.content.length) {
          data.content.push(
            {label : "Add user " + event.target.value + "..."
            , email : !~event.target.value.indexOf("@") ? "" : event.target.value
            , name : !~event.target.value.indexOf("@") ? event.target.value : ""
            , id : null });
        }
      }
  }
  , _renderItem : function(ul, item) {
    var label = item.name ? item.name + " (" + item.label + ")" : item.label;
    return $( "<li class='inline-search-result'>" )
        .data( "item.autocomplete", item )
        .append( "<a>" + escapeHTML(label) + "</a>" )
        .appendTo( ul );
  }
  });
$.widget.bridge("pbc_autocomplete_people", $.pbc.autocomplete_people);

$.widget(
  "pbc.autocomplete_documents"
  , $.pbc.autocomplete
  , { options : {
      source : CMS.Models.Document.search
      , select :  function(event, ui) {
        $(event.target).trigger("documentSelected", ui.item);
        return false;
      }
      , search : function(event) {

      }
      , response : function(event, data, ui) {
        if(!data.content.length) {
          data.content.push(
            {label : "+ Document " + event.target.value + "..."
            , link_url : event.target.value
            , id : null });
        }
      }
  }
  , _renderItem : function(ul, item) {
    var label;
    if (item.label) {
      label = item.label
    } else if (item.title) {
      label = "" + item.title + (item.link_url ? " (" + item.link_url + ")" : "");
    } else {
      label = item.link_url;
    }
    return $( "<li class='inline-search-result'>" )
        .addClass(item.id ? "" : "error")
        .data( "item.autocomplete", item )
        .append( "<a>" + escapeHTML(label) + "</a>" )
        .appendTo( ul );
  }
  });
$.widget.bridge("pbc_autocomplete_documents", $.pbc.autocomplete_documents);

$(function() {

    var pbc_list_id = (/\/pbc_lists\/(\d+)/.exec(window.location.pathname) || [])[1];

    function init_responses_controller(display_prefs) {
        var filter_element = $(this).closest("[data-filter-id]")
        $(this).closest(".main-item")
        .find(".pbc-responses-container")
        .cms_controllers_responses({
          id : filter_element.data("filter-id")
          , type_id : filter_element.data("filter-type-id")
          , type_name : filter_element.data("filter-type-name")
          , display_prefs : display_prefs
          , page_id : pbc_list_id
        });
    }

    if(pbc_list_id) {
      CMS.Models.DisplayPrefs.findAll().done(function(prefs) {
        var d = prefs[0];
        if(!d) {
          d = new CMS.Models.DisplayPrefs().save();
        }

        // Trigger controller load when collapsed container is expanded
        $(document.body).on("click", ".pbc-requests .pbc-item-head .openclose", function(ev) {
          init_responses_controller.call(this, d);
          d.setPbcRequestOpen(pbc_list_id, $(this).closest("li").data("filter-id"), $(this).is(".active"))
        });

        $(".pbc-requests > li").each(function(i, req) {
          if(d.getPbcRequestOpen(pbc_list_id, $(req).data("filter-id"))) {
            $(this).find(".openclose").openclose("open");
            init_responses_controller.call(this, d);
          }
        })

      });
    }

    //$(".pbc-system-search").pbc_autocomplete();

    // Using rotate_flow_control_assessment route
    $('body').on('ajax:success', 'a.rotate_control_assessment', function(data) {
      var $this = $(this)
        , $icon = $this.find('i')
        ;

      if ($this.hasClass('btn-success')) {
        // success state -> blank state
        $this.removeClass('btn-success');
        $icon.removeClass('grcicon-check-white').addClass('grcicon-blank');
      } else if ($this.hasClass('btn-warning')) {
        // failure state -> success state
        $this.removeClass('btn-warning').addClass('btn-success');
        $icon.removeClass('grcicon-x-white').addClass('grcicon-check-white');
      } else {
        // blank state -> failure state
        $this.addClass('btn-warning');
        $icon.removeClass('grcicon-blank').addClass('grcicon-x-white');
      }
    });

    $(document.body).cms_controllers_pbc_modals({});
});

})(this, can.$);
