class PopulationSamplesController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#  end

  layout 'dashboard'

  no_base_action :index, :show, :tooltip

  private

    def object_path
      flow_pbc_list_path(@population_sample.response.request.pbc_list_id)
    end

    def post_destroy_path
      flow_pbc_list_path(@population_sample.response.request.pbc_list_id)
    end

    def population_sample_params
      population_sample_params = params[:population_sample] || {}
      if population_sample_params[:response_id]
        population_sample_params[:response] = Response.where(:id => population_sample_params.delete(:response_id)).first
      end
      %w(population_document sample_worksheet_document sample_evidence_document).each do |field|
        if population_sample_params.has_key? "#{field}_id" then
          population_sample_params[field] = Document.where(:id => population_sample_params.delete("#{field}_id")).first
        end

      end
      population_sample_params
    end
end
