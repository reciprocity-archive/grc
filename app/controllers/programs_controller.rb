# Browse programs
class ProgramsController < BaseObjectsController

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_program
    end

    actions :edit, :update do
      allow :update, :update_program, :of => :program
    end

    actions :show, :tooltip do
      allow :read, :read_program, :of => :program
    end

    actions :index do
      allow :read, :read_program
    end
  end

  layout 'dashboard'

  def index
    @programs = Program
    if params[:s].present?
      @programs = @programs.db_search(params[:s])
    end
    @programs = allowed_objs(@programs.all, :read)

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

  private

    def delete_model_stats
      [ [ 'Directive', @program.directives.count ]
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
