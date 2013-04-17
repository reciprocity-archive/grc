//require can.jquery-all

(function(can) {

can.Model.Cacheable("CMS.Models.Program", {
  root_object : "program"
  , findAll : "/programs.json?company_controls_first=true"
}, {});

can.Model.Cacheable("CMS.Models.Directive", {
  root_object : "directive"
  , findAll : "/directives.json"
  , findOne : "/directives/{id}.json"
}, {
  lowercase_kind : function() { return this.kind.toLowerCase() }
});

CMS.Models.Directive("CMS.Models.Regulation", {
  findAll : "/directives.json?meta_kind=regulation"
}, {});

CMS.Models.Directive("CMS.Models.Policy", {
  findAll : "/directives.json?meta_kind=policy"
}, {});

CMS.Models.Directive("CMS.Models.Contract", {
  findAll : "/directives.json?meta_kind=contract"
}, {});

can.Model.Cacheable("CMS.Models.OrgGroup", {
  root_object : "org_group"
  , findAll : "/org_groups.json"
}, {});

can.Model.Cacheable("CMS.Models.Project", {
  root_object : "project"
  , findAll : "/projects.json"
}, {});

can.Model.Cacheable("CMS.Models.Facility", {
  root_object : "facility"
  , findAll : "/facilities.json"
}, {});

can.Model.Cacheable("CMS.Models.Product", {
  root_object : "product"
  , findAll : "/products.json"
}, {});

can.Model.Cacheable("CMS.Models.DataAsset", {
  root_object : "data_asset"
  , findAll : "/data_assets.json"
}, {});

can.Model.Cacheable("CMS.Models.Market", {
  root_object : "market"
  , findAll : "/markets.json"
}, {});

can.Model.Cacheable("CMS.Models.RiskyAttribute", {
  root_object : "risky_attribute"
  , findAll : "/risky_attributes.json"
}, {});

can.Model.Cacheable("CMS.Models.Risk", {
  root_object : "risk"
  , findAll : function(params) {
    var root_object =  this.root_object;
    return $.ajax({
      url : "/risks.json"
      , type : "get"
      , data : params
      , dataType : "json" 
    }).then(function(risks) {
      can.each(risks, function(r) {
        if(r[root_object].hasOwnProperty("trigger")) {
          r[root_object].risk_trigger = r[root_object].trigger;
          delete r[root_object].trigger;
        }
      });
      return risks;
    });
  }
}, {});

})(this.can);