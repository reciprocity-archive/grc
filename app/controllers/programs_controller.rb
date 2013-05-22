# Browse programs
class ProgramsController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#
#    actions :new, :create do
#      allow :create, :create_program
#    end
#
#    actions :edit, :update do
#      allow :update, :update_program, :of => :program
#    end
#
#    actions :show, :tooltip do
#      allow :read, :read_program, :of => :program
#    end
#
#    actions :index do
#      allow :read, :read_program
#    end
#  end

  layout 'dashboard'

  def index
    @programs = Program
    if params[:s].present?
      @programs = @programs.db_search(params[:s])
    end
    if params[:kind].present?
      @programs = @programs.where(:kind => params[:kind])
    end
    @programs = allowed_objs(@programs.all, :read)
    if params[:company_controls_first].present?
      @programs =
        @programs.select { |p| p.company_controls? } +
        @programs.reject { |p| p.company_controls? }
    end

     respond_to do |format|
      format.html do
        if params[:quick]
          render :partial => 'quick', :locals => { :quick_result => params[:qr]}
        end
      end
      format.json do
        render :json => @programs
      end
    end
  end

  def sections
    @sections = Section.
      joins(:directive => :program_directives).
      where(:program_directives => { :program_id => params[:id] }).
      includes(:controls => :implementing_controls)
    if params[:s].present?
      @sections = @sections.fulltext_search(params[:s])
    end
    @sections = allowed_objs(@sections.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.json do
        render :json => @sections, :methods => [:linked_controls, :description_inline]
      end
    end
  end

  def controls
    @controls = Control.
      joins(:directive => :program_directives).
      where(:program_directives => { :program_id => params[:id] }).
      includes(:implementing_controls)
    if params[:s].present?
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
    respond_to do |format|
      format.json do
        render :json => @controls, :methods => [:implementing_controls, :description_inline]
      end
    end
  end

  private

    def delete_model_stats
      [ [ 'Cycle', @program.cycles.count ]
      ]
    end

    def program_params
      program_params = params[:program] || {}
      %w(start_date stop_date audit_start_date).each do |field|
        parse_date_param(program_params, field)
      end
      program_params
    end

end
