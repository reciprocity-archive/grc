# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Browse sections
class SectionsController < BaseObjectsController
  include DirectivesHelper

  cache_sweeper :section_sweeper, :only => [:create, :update, :destroy]

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_section
    end

    allow :read, :read_section, :of => :system, :to => [:show,
                                                        :tooltip]

    actions :edit, :update do
      allow :update, :update_section, :of => :section
    end
  end

  layout 'dashboard'

  private

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
      if section_params[:directive_id]
        # TODO: Validate the user has access to add sections to the directive
        section_params[:directive] = Directive.where(:id => section_params.delete(:directive_id)).first
      end
      section_params
    end
end
