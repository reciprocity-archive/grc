//= require can.jquery-all
//= require pbc/response
//= require pbc/system
//= require pbc/person

(function(can, $) {

function zeropad(v) {
  return "" + (v < 10 ? "0" + v : v);
 }

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
        this.bindXHRToButton(
          new CMS.Models.ObjectDocument({
            document_id : el.data("id")
            , system_id : this.selected_system_id
            , role : 'General Doc'
          }).save()
          , el);
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

    , ".delete-response click" : function(el, ev) {
      this.selected_response_id = el.closest("[data-id]").data("id");
    }

    , "a[data-method=delete][href*=responses] click" : function(el, ev) {
      var modal = el.closest(".modal")
      , options = modal.data("modal_form").options;

      el.addClass("disabled");

      this.bindXHRToButton(
        CMS.Models.Response.findInCacheById(options.id).destroy()
        .then(function() {
          modal.modal_form("hide");
        })
        , el);
      ev.preventDefault();
      ev.stopPropagation();
    }

    , '.pbc-control > a modal:select' : function(el, e, control_data) {
        var request_id = el.closest('li[data-filter-id]').data('filter-id')
        ;

      var xhr = $.post(
        '/requests/' + request_id,
        { _method: 'put'
        , 'request[control_id]': control_data.id
        }, function(data) {
          // FIXME: Brad, fix this if/when Requests are live-bound
          var $this = el.closest('.pbc-control').find('.control');
          $this.text("0 responses");
          $this.removeClass("error");
          $this.removeClass("control");
          $this.prev().hide();
          $this.next().hide();
            //find this control AND REMOVE ITS ERROR
            var $requests = $("#requests");
            var $ca = $requests.find(".pbc-ca[data-type=ControlAssessment][data-control-id=" + control_data.id + "]");
            var type_name = el.closest('li[data-filter-type-name]').data("filter-type-name");

            // case 1: control exists -- no action needed
            if(!$ca.length) {
              // case 2: control does not exist
              $requests.append(
                can.view(
                    "/assets/pbc/control_assessment.mustache"
                    , $.extend({}, control_data, { type_name : type_name, control_assessment_id : data.control_assessment_id })
                ));
              $ca = $requests.find(".pbc-ca[data-control-id=" + control_data.id + "]");

              
            }
            var $oldParent = el.closest(".pbc-ca");
            el.closest(".requests > *").detach().appendTo($ca.find(".requests"));
            //$ca.find(".pbc-ca-title .expander").addClass("in");
            var content = $ca.children(".item-content");
            content.show();
            $ca.children(".item-main").find(".openclose").addClass("active");
            // sweep for newly empty control assessments and delete.
            $requests.find(".pbc-ca:not(:has(.requests *))").remove();
        });
        this.bindXHRToButton(xhr, el);
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
      this.generate_calendar_href(el, ev);
    }

    , ".modal[id*=meetings-new] loaded" : function(el, ev) {
      var n = new Date(Date.now() + 3600000);
      $(el).find("input[name=fromdate]").val(zeropad(n.getMonth() + 1) + "/" + zeropad(n.getDate()) + "/" + n.getFullYear());
      $(el).find("select[name=fromtime]").val(zeropad(n.getHours()) + "0000");
      n = new Date(n.getTime() + 3600000);
      $(el).find("select[name=totime]").val(zeropad(n.getHours()) + "0000");

      this.generate_calendar_href($(el).find("input[name=fromdate]"), ev);    
    } 

    , generate_calendar_href : function(el, ev) { 
      var cal_link = $(el).closest(".modal").find(".create-gcal-event");
      var form = $(el).closest("form")[0];
      var href = cal_link.attr("href");

      if(form.fromdate.value === "")
        return;

      function rearrange(a) {
        a.unshift(a.pop());
        return a;
      }

      function toUTCTime(date, time) {
        var offset = new Date().getTimezoneOffset() / 60;
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

        return year.toString() + zeropad(month) + zeropad(days) + "T" + zeropad(hours) + zeropad(minutes) + time.substr(4,2) + "Z";

      }


      href = href.replace(
        /dates=[^&]*/
        , "dates="
        + toUTCTime(rearrange(form.fromdate.value.split('/')).join(''), form.fromtime.value)
        + "/"
        + toUTCTime(rearrange(form.fromdate.value.split('/')).join(''), form.totime.value)
        )
      cal_link.attr("href", href);
    }
});

})(window.can, can.$);
