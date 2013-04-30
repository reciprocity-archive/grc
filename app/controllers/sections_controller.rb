# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Browse sections
class SectionsController < BaseObjectsController
  include DirectivesHelper

  cache_sweeper :section_sweeper, :only => [:create, :update, :destroy]

#  access_control :acl do
#    allow :superuser
#
#    actions :new, :create do
#      allow :create, :create_section
#    end
#
#    allow :read, :read_section, :of => :system, :to => [:show,
#                                                        :tooltip]
#
#    actions :edit, :update do
#      allow :update, :update_section, :of => :section
#    end
#  end

  layout 'dashboard'

  def index
    @sections = Section
    if params[:s].present?
      @sections = @sections.fulltext_search(params[:s])
    end
    if params[:directive_id].present?
      @sections = @sections.where(:directive_id => params[:directive_id])
    end
    if params[:program_id].present?
      @sections = @sections.joins(:directive => :program_directives).where(:program_directives => { :program_id => params[:program_id] })
    end

    @sections = allowed_objs(@sections.all, :read)
    @sections.sort_by(&:slug_split_for_sort)

    respond_to do |format|
      format.json do
        if params[:ids_only].present?
          render :json => @sections, :only => [:id]
        else
          render :json => @sections, :methods => [:description_inline]
        end
      end
    end
  end

  private

    def create_object_as_json
      object.as_json :methods => [:description_inline, :linked_controls]
    end

    def update_object_as_json
      object.as_json :methods => [:description_inline, :linked_controls]
    end

    def extra_delete_relationship_stats
      [ [ 'Control', @section.control_sections.count ],
      ]
    end

    def object_path
      flow_directive_path(@section.directive)
    end

    def post_destroy_path
      flow_directive_path(@section.directive)
    end

    def section_params
      section_params = params[:section] || {}
      if section_params[:parent_id]
        section_params[:parent] = Section.where(:id => section_params.delete(:parent_id)).first
      end
      if section_params[:directive_id]
        # TODO: Validate the user has access to add sections to the directive
        section_params[:directive] = Directive.where(:id => section_params.delete(:directive_id)).first
      end
      section_params
    end
end
