//= require can.jquery-all
//= require pbc/response
//= require pbc/system
//= require pbc/person

can.Control("CMS.Controllers.PBCModals", {
    defaults : {}
}, {
    init : function() {
        var content = $(".pbc-ca-content");
        content.collapse();
    }

    , ".add-document click" : function(el, ev) {
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
        var request_id = el.closest('li[data-filter-id]').data('filter-id')
        ;

      $.post(
        '/requests/' + request_id,
        { _method: 'put'
        , 'request[control_id]': control_data.id
        }, function(data) {
          // FIXME: Brad, fix this if/when Requests are live-bound
          var $this = el.closest('.pbc-control').find('.item');
          $this.text(control_data.slug);
          $this.removeClass("error");
          $this.addClass("i-control");
            //find this control AND REMOVE ITS ERROR
            var $ca = $(".pbc-control-assessments .pbc-ca-item[data-type=ControlAssessment][data-control-id=" + control_data.id + "]");
            var type_name = el.closest('li[data-filter-type-name]').data("filter-type-name");

            // case 1: control exists -- no action needed
            if(!$ca.length) {
              // case 2: control does not exist
              $(".pbc-control-assessments").append(
                can.view(
                    "/assets/pbc/control_assessment.mustache"
                    , $.extend({}, control_data, { type_name : type_name})
                ));
              $ca = $(".pbc-control-assessments .pbc-ca-item[data-control-id=" + control_data.id + "]");

              
            }
            var $oldParent = el.closest(".pbc-ca-item");
            el.closest(".pbc-requests > .main-item").detach().appendTo($ca.find(".pbc-requests"));
            //$ca.find(".pbc-ca-title .expander").addClass("in");
            var content = $ca.find(".pbc-ca-content");
            content.collapse().collapse("show");
            $ca.find("[data-toggle=#" + content.attr("id") + "]").addClass("in");
            // sweep for newly empty control assessments and delete.
            $(".pbc-control-assessments .pbc-ca-item:not(:has(.main-item))").remove();

            /*
            Due to request counts being removed by story 41602953, this code is not currently
             working or needed.  If request counts are restored, uncomment this block.  --BM
            var filtersmap = {
                "Documentation" : ".grcicon-document"
                , "Population Sample" : ".grcicon-populationsample"
                , "Interview" : ".grcicon-calendar"
            };

            var targetTextNode = $ca.find(".pbc-ca-title " + filtersmap[type_name])[0].nextSibling;
            targetTextNode.nodeValue = [" ", parseInt(targetTextNode.nodeValue) + 1, " "].join("");
            targetTextNode =  $oldParent.find(".pbc-ca-title " + filtersmap[type_name])[0].nextSibling;
            targetTextNode.nodeValue = [" ", parseInt(targetTextNode.nodeValue) - 1, " "].join("");
            */
        });
    }

    , '.pbc-control-select > a modal:select' : function(el, e, control_data) {
      var $this = $(el)

      $this.closest('.pbc-control-select').find('.item').text(control_data.slug);

      $("#request_control_id").val(control_data.id)
    }

    , ".items-list[id$=new] shown" : function(el, ev) {
        $("[data-target='#" + $(el).attr("id") + "']").closest("[data-toggle=modal]").hide()
        $(el).find("input[type=text]:first").focus();
    }

    , ".items-list[id$=new] hidden" : function(el, ev) {
        $("[data-target='#" + $(el).attr("id") + "']").closest("[data-toggle=modal]").show()
    }

    , ".modal input[name=fromdate], .modal input[name=todate], .modal select[name=fromtime], .modal select[name=totime] change" : function(el, ev) {
      var cal_link = $(el).closest(".modal").find(".create-gcal-event");
      var form = $(el).closest("form")[0];
      var href = cal_link.attr("href");

      if(form.fromdate.value === "" || form.todate.value === "")
        return;

      function rearrange(a) {
        a.unshift(a.pop());
        return a;
      }

      function toUTCTime(date, time) {
        var offset = new Date(1970, 0, 1, 0, 0, 0).getTime() / 1000 / 60 / 60;
        var hours = +(time.substr(0,2)) + offset;
        var minutes = +(time.substr(2,2));

        var offset_minutes = (offset - parseInt(offset)) * 60;
        if(offset_minutes !== 0) {
          minutes += offset_minutes;
          if(minutes > 59) {
            hours++;
            minutes -= 60;
          } else if(minutes < 0) {
            hours--;
            minutes += 60;
          }
        }

        var year = +(date.substr(0, 4));
        var month = +(date.substr(4, 2));
        var days = +(date.substr(6, 2));
        if(hours > 23) {
          days++;
          hours -= 24;
        } else if(hours < 0) {
          days--;
          hours += 24;
        }

        function getMonthLength(m) {
          switch(m) {
          case 9: case 4: case 6: case 11:
            return 30;
            break;
          case 2:
            return !(year % 400) ? 29 : (!(year % 100) ? 28 : (!(year % 4) ? 29 : 28));
            break;
          default:
            return 31;
          }
        }

        if(days < 1) {
          month--;
          days += getMonthLength(month);
        } else if(days > getMonthLength(month)) {
          days -= getMonthLength(month);
          month++;
        }

        if(month > 12) {
          year++;
          month -= 12;
        } else if (month < 1) {
          year--;
          month += 12
        }

        function zeropad(v) {
          return "" + (v < 10 ? "0" + v : v);
         }

        return year.toString() + zeropad(month) + zeropad(days) + "T" + zeropad(hours) + zeropad(minutes) + time.substr(4,2) + "Z";

      }


      href = href.replace(
        /dates=[^&]*/
        , "dates="
        + toUTCTime(rearrange(form.fromdate.value.split('/')).join(''), form.fromtime.value)
        + "/"
        + toUTCTime(rearrange(form.todate.value.split('/')).join(''), form.totime.value)
        )
      cal_link.attr("href", href);
    }
});
