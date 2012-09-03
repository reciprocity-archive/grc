/* =========================================================
 * Extra scripts for beta designs
 * ========================================================= */

/*
 *= require dashboard
 *= require wysihtml5-0.3.0_rc2
 *= require bootstrap-wysihtml5-0.0.2
 *= require bootstrap-datepicker
 */

$(function () {

  //render out templates function
  var renderExternalTmpl = function(item) {
    var file = '/design/templates/' + item.name;
    if ($(item.selector).length > 0) {
      $.when($.get(file)).done(function(tmplData) {
        $(item.selector).append(tmplData)
        //$.templates({ tmpl: tmplData });
        //$(item.selector).append($.render.tmpl(item.data));
      });
    }
  }

  //ACTUALLY renderout templates
  renderExternalTmpl({ name: 'help', selector: '#templates', data: {} });

  renderExternalTmpl({ name: 'confirm', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'comingsoon', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newasset', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newentity', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newfacility', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newsystem', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newcontrol', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'auditcycle', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'peopleselector', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'referenceselector', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newperson', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newreference', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newentity', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newproduct', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newsection', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newthreat', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'mappedcontrols', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'newprogram', selector: '#templates', data: {} });
  // new modals START
  renderExternalTmpl({ name: 'redesignNewProgram', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'redesignNewProgramWide', selector: '#templates', data: {} });
  // new modals END
  renderExternalTmpl({ name: 'newpersonBasic', selector: '#templates', data: {} });

  renderExternalTmpl({ name: 'newtransaction', selector: '#templates', data: {} });

  renderExternalTmpl({ name: 'auditdefaultscope', selector: '#templates', data: {} });

  renderExternalTmpl({ name: 'sendauditorinvite', selector: '#templates', data: {} });

  renderExternalTmpl({ name: 'neauditscheduleitem', selector: '#templates', data: {} });

  renderExternalTmpl({ name: 'auditmeetingnotice', selector: '#templates', data: {} });


  //<!-- Content templates ->
  renderExternalTmpl({ name: 'examplecontrols', selector: '#Controls', data: {} });
  renderExternalTmpl({ name: 'exampleregulations', selector: '#Regulation', data: {} });
  renderExternalTmpl({ name: 'exampleauditorrequests', selector: '#requests', data: {} });
  renderExternalTmpl({ name: 'examplesysproc', selector: '#sysproc', data: {} });

  renderExternalTmpl({ name: 'examplecombo', selector: '#Combo', data: {} });
  renderExternalTmpl({ name: 'auditstatus', selector: '#auditstatus', data: {} });

  $(document).on("click", "#expand_all", function(event) {
    //$('.row-fluid-slotcontent').show("fast");
    $('.row-fluid-slotcontent').addClass("in");
    $('.expander').addClass("toggleExpanded");
  });

  $(document).on("click", "#shrink_all", function(event) {
    //$('.row-fluid-slotcontent').hide("fast");
    $('.row-fluid-slotcontent').removeClass("in");
    $('.expander').removeClass("toggleExpanded");
  });

  /*Checkbutton in modals widget function*/
  $(document).on("click", ".checkbutton", function(event) {
    $(this).children("i").toggleClass("gcmsicon-blank");
    $(this).children("i").toggleClass("gcmsicon-x-grey");
  });

  /*Toggle widget function*/
  $(document).on("click", ".accordion-toggle", function(event) {
    $(this).children("i").toggleClass("gcmssmallicon-blue-expand");
  });

  /*Toggle slot function*/
  // Handled by rotation of expander icon
  /*$(document).on("click", ".toggle", function(event){
    $(this).children(".expander").toggleClass("toggleExpanded");
  });*/

  $(document).on("click", ".expandAll", function(event) {
    // $("h3.trigger").toggleClass("active").next().slideToggle("fast");
    $(this).children("i").toggleClass("gcmssmallicon-blue-expand");
  });

  //Handle remove buttons
  $(document).on("click", ".removeCircleButton", function(event){
    //alert("here");
    $('#confirmModal').on('hidden', function () {
      $(this).closest('.controlSlot').remove();
    })
    $('#confirmModal').modal('show');
  });

  $('#myModal').on('hidden', function () {
    // do something…
  })

  $(document).on("click", ".greyOut", function(event){
    $(this).closest('.singlecontrolSlot').remove();
  });

  $(".addpersonItem").click(function () {
    $('#modalpeopleList').append("<li class='controlSlot ui-draggable'><div class='arrowcontrols-group'> <div class='controls-type'>Controls-Type</div><div class='controls-subtype'> <a class='dropdown-toggle statustextred' data-toggle='dropdown' href='#'>Select Role</a> <ul class='dropdown-menu dropdown-menusmall'><li>Owner</li><li>User</li></ul> </div>  <div class='controls-subgroup'>Controls-Subgroup</div></div><a class='personItem'><div class='removeCircleButton fltrt'><i class='gcmssmallicon-dash-white'></i></div></a></li>");
  });

  $(".referenceItem").click(function () {
    $('#referenceList').append("<li class='controlSlot'><a href='#'><div class='circle fltrt'><i class='gcmssmallicon-dash-white'></i></div></a><span class='controls-group'>Reference Type</span><br /><span class='controls-subgroup'>Reference Item</span></li>");
  });

  $(".collapse").collapse();
  $('#quicklinks a:last').tab('show');

  $('#myLock a').click(function (e) {
      e.preventDefault();
      alert("here");
      $('#programinformationLocked').tab('hide');
      $('#programinformationUnlocked').tab('show');
  });

  for (i=0;i<=5;i++) {
    $('#tooltip' + i).tooltip();
  }

});


function toggleCompliance() {
  $('.compWidget').fadeToggle("slow", "linear");
}

function toggleRisk() {
  $('.riskWidget').fadeToggle("slow", "linear");
}

function toggleGovernance() {
  $('.govWidget').fadeToggle("slow", "linear");
}


