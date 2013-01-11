(function(can, $) {
  
  can.Model.Cacheable("CMS.Models.PopulationSample", {
    root_object : "population_sample"
    , update : function(id, params) {
      var _params = this.process_args(params, ["population_document_id", "sample_worksheet_document_id", "sample_evidence_document_id"]);
      return $.ajax({
        type : "put"
        , url : "/population_samples/" + id + ".json"
        , dataType : "json"
        , data : _params
      });
    }
  }, {

    init : function () {
        this._super && this._super.apply(this, arguments);

        var that = this;

        this.each(function(value, name) {
          if (value === null)
            that.attr(name, "");
        });
    }

  });

})(can, can.$);