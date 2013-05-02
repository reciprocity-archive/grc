# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

require 'csv'

class DirectivesController < BaseObjectsController
  # FIXME: Decide if the :section, controls, etc.
  # methods should be moved, and what access controls they
  # need.
  before_filter :load_directive, :only => [:export_controls,
                                           :export,
                                           :import_controls,
                                           :import,
                                           :sections,
                                           :controls,
                                           :section_controls,
                                           :control_sections,
                                           :category_controls]

  cache_sweeper :section_sweeper, :only => [:destroy, :import]
  cache_sweeper :control_sweeper, :only => [:destroy, :import_controls]

#  access_control :acl do
#    allow :superuser
#
#    allow :create, :create_directive, :to => [:create,
#                                   :new]
#    allow :read, :read_directive, :of => :directive, :to => [:show,
#                                                  :tooltip,
#                                                  :sections,
#                                                  :controls,
#                                                  :section_controls,
#                                                  :control_sections,
#                                                  :category_controls]
#
#    allow :update, :update_directive, :of => :directive, :to => [:edit,
#                                                    :update,
#                                                    :import_controls,
#                                                    :export_controls,
#                                                    :import,
#                                                    :export]
#  end

  layout 'dashboard'

  def index
    @directives = Directive
    if params[:relevant_to].present?
      @directives = @directives.relevant_to(Product.find(params[:relevant_to]))
    end
    if params[:s].present?
      directive_ids = @directives.db_search(params[:s]).map { |d| d.id }
      if params[:search_sections].present?
        directive_ids = directive_ids + Section.
          includes(:directive).
          db_search(params[:s]).
          all.
          map { |s| s.directive_id }
      end
      @directives = @directives.where(:id => directive_ids)
    end
    if params[:meta_kind].present?
      @directives = @directives.where(:kind => Directive.kinds_for(params[:meta_kind]))
    end
    if params[:program_id].present?
      @directives = @directives.joins(:program_directives).where(:program_directives => { :program_id => params[:program_id] })
    end
    @directives = allowed_objs(@directives.all, :read)
    @directives = @directives.reject(&:is_stealth_directive?)

    respond_to do |format|
      format.html do
        if params[:quick].present?
          render :partial => 'quick', :locals => { :quick_result => params[:qr]}
        end
        if params[:tree].present?
          render :partial => 'tree', :locals => { :directives => @directives }
        end
      end
      format.json do
        render :json => @directives, :methods => :description_inline
      end
    end
  end

  def export_controls
    respond_to do |format|
      format.html do
        render :layout => 'export_modal', :locals => { :directive => @directive }
      end
      format.csv do
        filename = "#{@directive.slug}-controls.csv"
        handle_converter_csv_export(filename, @directive.controls.all, ControlsConverter, :directive => @directive)
      end
    end
  end

  def export
    respond_to do |format|
      format.html do
        render :layout => 'export_modal', :locals => { :directive => @directive }
      end
      format.csv do
        filename = "#{@directive.slug}.csv"
        handle_converter_csv_export(filename, @directive.sections.all, SectionsConverter, :directive => @directive)
      end
    end
  end

  def import_controls
    handle_csv_import(ControlsConverter, :template => 'import_controls_result', :directive => @directive) do |converter|
      flash[:notice] = "<i class='grcicon-ok'></i> #{@import.created_objects.size + @import.updated_objects.size} Controls are Imported Successfully!".html_safe
      keep_flash_after_import
      render :json => { :location => flow_directive_path(@directive) }
    end
  end

  def import
    handle_csv_import(SectionsConverter, :directive => @directive) do |converter|
      flash[:notice] = "Successfully imported #{@import.created_objects.size + @import.updated_objects.size} #{@directive.section_meta_kind.to_s.pluralize}"
      keep_flash_after_import
      render :json => { :location => flow_directive_path(@directive) }
    end
  end

  def sections
    @sections = @directive.sections.includes(:controls => :implementing_controls)
    if params[:s]
      @sections = @sections.fulltext_search(params[:s])
    end
    @sections = allowed_objs(@sections.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.html do
        render :layout => nil, :locals => { :sections => @sections }
      end
      format.json do
        render :json => @sections, :methods => [:linked_controls, :description_inline]
      end
    end
  end

  def section_controls
    if @directive.company?
      @sections = @directive.controls.includes(:implemented_controls => { :control_sections => :section }).map { |cc| cc.implemented_controls.map { |ic| ic.control_sections.map { |cs| cs.section } }.flatten }.flatten.uniq
    else
      @sections = @directive.sections.includes(:controls => :implementing_controls).all
    end
    @sections.sort_by(&:slug_split_for_sort)
    @sections = allowed_objs(@sections, :read)
    render :layout => nil, :locals => { :sections => @sections }
  end

  def control_sections
    @controls = @directive.controls.includes(:sections)
    if params[:s]
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.html do
        render :layout => nil, :locals => { :controls => @controls }
      end
      format.json do
        render :json => @controls.map {|o| o.id}
      end
    end
  end

  def category_controls
    categories = Category.ctype(Control::CATEGORY_TYPE_ID).roots.all
    @category_tree = categories.map do |category|
      category_controls_tree(@directive, category)
    end.compact

    uncategorized_controls = Control.
      includes(:categorizations).
      where(
        :directive_id => @directive.id,
        :categorizations => { :categorizable_id => nil }).
      all

    if !uncategorized_controls.empty?
      @category_tree.push([nil, nil, uncategorized_controls])
    end

    render :layout => nil
  end

  def new_object_title
    "Directive or Policy"
  end

  private

    def show_set_page_types
      super
      @page_subtype = object.meta_kind.to_s.underscore.pluralize
    end

    # Construct the category controls tree
    #   - if neither the current category nor descendants contains controls
    #     then return nil
    #   - else return [category, category_controls_tree(category), controls]
    def category_controls_tree(directive, category)
      controls = category.controls.where(:directive_id => directive).all
      children = category.children.all.map do |subcategory|
        category_controls_tree(directive, subcategory)
      end.compact
      if controls.size > 0 || children.size > 0
        [category, children, controls]
      else
        nil
      end
    end

    def delete_model_stats
      [ [ 'Section', @directive.sections.count ],
        [ 'Control', @directive.controls.count ]
      ]
    end

    def load_directive
      @directive = Directive.find(params[:id])
    end

    def directive_params
      directive_params = params[:directive] || {}
      if directive_params[:type]
        directive_params[:company] = (directive_params.delete(:type) == 'company')
      end
      %w(start_date stop_date audit_start_date).each do |field|
        parse_date_param(directive_params, field)
      end
      %w(audit_frequency audit_duration).each do |field|
        parse_option_param(directive_params, field)
      end
      directive_params
    end

end
