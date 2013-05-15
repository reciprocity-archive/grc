# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Handle Documents
class DocumentsController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#
#    actions :create, :new do
#      allow :create, :create_document
#    end
#
#    actions :show do
#      allow :read, :read_document, :of => :document
#    end
#
#    actions :index do
#      allow :read, :read_document
#    end
#
#    actions :edit, :update do
#      allow :update, :update_document, :of => :document
#    end
#
#    actions :destroy do
#      allow :destroy, :delete_document, :of => :document
#    end
#  end

  layout 'dashboard'

  no_base_action :tooltip

  def index
    @documents = Document
    if params[:s].present?
      @documents = @documents.db_search(params[:s])
    end
    @documents = allowed_objs(@documents.all, :read)
    if params[:list_select].present?
      render :partial => 'list_select', :layout => 'layouts/list_select_modal', :locals => {}
    else
      render :json => @documents, :methods => [:document_type, :link_url]
    end
  end

  private

    def object_as_json(args=nil)
      super(:methods => [:descriptor, :link_url])
    end

    def extra_delete_relationship_stats
        ObjectDocument.where(:document_id => @document.id).all.map do |od|
          documentation_type = od.documentable_type == 'Response' ? 'Documentation Response' : od.documentable_type
          #documentation_type = documentation_type == 'Document' ? 'Document Reference' : documentation_type
          [documentation_type, od.documentable]
        end +
      [
        ['Population Sample Response', @document.count_population_samples]
      ] 
    end

    def document_params
      document_params = params[:document] || {}
      %w(type kind year language).each do |field|
        parse_option_param(document_params, field)
      end
      document_params
    end
end
