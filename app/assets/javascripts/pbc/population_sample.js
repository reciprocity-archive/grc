(function(can, $) {
  
  can.Model.Cacheable("CMS.Models.PopulationSample", {
    root_object : "population_sample"
    , update : function(id, params) {
      var _params = this.process_args(params, ["population", "samples", "population_document_id", "sample_worksheet_document_id", "sample_evidence_document_id"]);
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

        can.each(
          ["population_document", "sample_worksheet_document", "sample_evidence_document"]
          , function(d) {
            if(!(that[d] instanceof CMS.Models.Document))
              that.attr(d, new CMS.Models.Document(that[d] && that[d].serialize ? that[d].serialize() : that[d]));
          });

        function reinit(ev) {
          // can.each(that, function(value, name) {
          //   if (value === null)
          //     that.attr(name, "");
          // });
        }
        reinit();
        this.bind("updated", reinit)
    }

  });

})(can, can.$);