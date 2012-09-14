/* =========================================================
 * Extra scripts for beta designs
 * ========================================================= */

/*
 *= require dashboard
 *= require jquery.cookie
 *= require wysihtml5-0.3.0_rc2
 *= require bootstrap-wysihtml5-0.0.2
 *= require bootstrap-datepicker
 */

jQuery(function ($) {

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
  renderExternalTmpl({ name: 'mappedcontrolsfull', selector: '#templates', data: {} });
  
  renderExternalTmpl({ name: 'newprogram', selector: '#templates', data: {} });
  // new modals START
  renderExternalTmpl({ name: 'redesignNewProgram', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'redesignSelectPersonWide', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'redesignNewProgramWide', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'redesignNewProgramWide2', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'redesignNewControlWide', selector: '#templates', data: {} });
  renderExternalTmpl({ name: 'redesignNewSectionWide', selector: '#templates', data: {} });

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

  //$(".collapse").collapse();
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

  // show/hide widget

  $('body').on('click', '.widget-trigger', function(e) {
    e.preventDefault();
    var $this = $(this),
        $widgetBody = $this.closest(".widget").find(".widget-body"),
        $icon = $this.find("i");

    if( $this.hasClass("active") ) {
      $widgetBody.slideUp("fast");
      $this.removeClass("active");
      $icon
        .removeClass("icon-chevron-down")
        .addClass("icon-chevron-right");
    } else {
      $widgetBody.slideDown("fast");
      $this.addClass("active");
      $icon
        .removeClass("icon-chevron-right")
        .addClass("icon-chevron-down");
    }

  });

  // show/hide list item

  $('body').on('click', '.list-trigger', function(e) {
    e.preventDefault();
    var $this = $(this),
        $listBody = $this.closest(".wlist-title").next(),
        $icon = $this.find("i");

    if( $this.hasClass("active") ) {
      $listBody.slideUp("fast");
      $this.removeClass("active");
      $icon
        .removeClass("icon-chevron-down")
        .addClass("icon-chevron-right");
    } else {
      $listBody.slideDown("fast");
      $this.addClass("active");
      $icon
        .removeClass("icon-chevron-right")
        .addClass("icon-chevron-down");
    }

  });

  // nicer hover

  $('body').on('mouseenter', '.people-list li', function(e) {
    $(this).find(".additional").slideDown("fast");
  });

  $('body').on('mouseleave', '.people-list li', function(e) {
    $(this).find(".additional").slideUp("fast");
  });


  // add item in target list

  $('body').on('click', '.add-me', function(e) {
    
    e.preventDefault();
    
    var $this = $(this),
        $icon = $this.find("i"),
        $itemToAdd = $this.closest("li"),
        $name = $itemToAdd.find(".name").html(),
        $company = $itemToAdd.find(".company").html(),        
        $target = $this.closest(".modal-body").find(".target");
    
    $this
      .addClass("btn-success");    
    $icon
      .removeClass("icon-chevron-right")
      .addClass("icon-ok")
      .addClass("icon-white");
    $target
      .prepend('<li class="new-item"><div class="row-fluid"><div class="span6"><span class="company">' + $company + '</span><span class="name">'+ $name +'</span></div><div class="span3"><span class="label">No relationship</span></div><div class="span3 actions"><a href="#" class="btn btn-mini pull-right"><i class="icon-minus-sign"></i></a><a href="#" class="btn btn-mini pull-right"><i class="icon-pencil"></i></a></div></div><div class="row-fluid additional"><div class="span6"><label>Relationship <strong>PENDING</strong></label><select class="span12"><option>No relationship</option><option>Is Accountable</option><option>Is Responsible</option></select></div><div class="span3"><label>Start Date</label><input class="span12" type="text" placeholder="MM/DD/YYYY"></div><div class="span3"><label>Stop Date</label><input class="span12" type="text" placeholder="MM/DD/YYYY"></div></div></li>')
      .find("li.new-item").hide().fadeIn('slow').removeClass("new-item");
  });

  // show filters in modals
  
  $('body').on('click', '#showFilters', function(e) {
    e.preventDefault();
    var $this = $(this),
        $filters = $this.closest(".modal-body").find(".filter-group"),
        $searchableLists = $this.closest(".modal-body").find(".filter-block .people-list");
        
    if( $this.hasClass("active") ) {
      $filters.hide();
      $this.removeClass("active");        
      $searchableLists.removeClass("short");
    } else {
      $filters.show();
      $this.addClass("active");
      $searchableLists.addClass("short");
    }
        
  });

  // status js
  var userHasPriviledge = true;
  $('body').on('click', '#actionButton', function(e) {
    e.preventDefault();

    var fullDate = new Date();
    var twoDigitMonth = ((fullDate.getMonth().length+1) === 1)? (fullDate.getMonth()+1) : '0' + (fullDate.getMonth()+1);
    var currentDate = fullDate.getDate() + "/" + twoDigitMonth + "/" + fullDate.getFullYear();

    var $this = $(this),
        $alert = $this.closest(".modal").find(".alert"),
        $date = $this.closest(".modal").find("#updatedDate"),
        $alertMessage = $this.closest(".modal").find("#alertMessage"),
        $status = $this.closest(".modal").find("#statusValue"),
        $currentStatus = $this.closest(".modal").find("#statusValue").html();

    if(userHasPriviledge) {

      if ($currentStatus === "Draft") {
        $status
          .html("Waiting for Approval")
          .addClass("statustextred");
        $alertMessage
          .html("New Program has been saved. Waiting on Approval.");
        $alert
          .fadeIn();
        $this
          .html("Approve");
        $date
          .html(currentDate);
      } else if ($currentStatus === "Waiting for Approval") {
        $status
          .html("Approved")
          .removeClass("statustextred");
        $alertMessage
          .html("Program has been approved.");
        $alert
          .fadeIn();
        $this
        .addClass("disabled");
        window.location = "/programs/1";
      }
    }
  });
});

function toggleRisk() {
  //$('.riskWidget').fadeToggle("fast", "linear");
  var interval = 200;
  $('.riskWidget').each(function(i){
    var el = $(this);
    if(el.hasClass('active')){
      $('#grcbutton-risk').addClass('halfopacity').removeClass('active');
      $.cookie('toggle_risk', null);
      el.delay(i*interval).slideUp(interval);
      el.removeClass('active');
    }else{
      $('#grcbutton-risk').removeClass('halfopacity').addClass('active');
      $.cookie('toggle_risk', '1', { expires: 1, path: '/' });
      el.delay(i*interval).slideDown(interval);
      el.addClass('active');
    }
  });

}

function toggleGovernance() {
   var interval = 200;
  $('.govWidget').each(function(i){
    var el = $(this);
    if(el.hasClass('active')){
      $('#grcbutton-governance').addClass('halfopacity').removeClass('active');
      $.cookie('toggle_governance', null);
      el.delay(i*interval).slideUp(interval);
      el.removeClass('active');
    }else{
      $('#grcbutton-governance').removeClass('halfopacity').addClass('active');
      $.cookie('toggle_governance', '1', { expires: 1, path: '/' });
      el.delay(i*interval).slideDown(interval);
      el.addClass('active');
    }
  });

}

jQuery(function($) {
  if ($.cookie('toggle_governance') == '1')
    toggleGovernance();
  else
    $('.govWidget').hide();
  if ($.cookie('toggle_risk') == '1')
    toggleRisk();
  else
    $('.riskWidget').hide();

  $('body').on('click', '#grcbutton-risk', function(e) {
    toggleRisk();
  });

  $('body').on('click', '#grcbutton-governance', function(e) {
    toggleGovernance();
  });
});
