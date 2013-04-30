class ProgramDirectivesController < BaseMappingsController

#  access_control :acl do
#    allow :superuser
#  end

  def index
    @objects = ProgramDirective
    if params[:program_id].present?
      @objects = @objects.where(:program_id => params[:program_id])
      if params[:directive_meta_kind].present?
        @objects = @objects.
          joins(:directive).
          where(:directives => { :kind => Directive.kinds_for(params[:directive_meta_kind]) })
      end
    end
    if params[:directive_id].present?
      @objects = @objects.where(:directive_id => params[:directive_id])
    end
    @objects = @objects.all
    render :json => @objects, :include => [:program, :directive]
  end

  private

    def list_edit_context
      form_params = {}
      form_params[:program_id] = params[:program_id] if params[:program_id].present?
      form_params[:directive_id] = params[:directive_id] if params[:directive_id].present?

      super.merge \
        :form_url => url_for({ :action => :create, :only_path => true }.merge(form_params))
    end

    def list_form_context
      if params[:program_id].present?
        object = Program.find(params[:program_id])
      elsif params[:directive_id].present?
        object = Directive.find(params[:directive_id])
      end

      super.merge :object => object
    end

    def update_object(object, object_params)
      object.program_id = object_params[:program_id]
      object.directive_id = object_params[:directive_id]
    end

    def default_as_json_options
      { :include => [:program, :directive] }
    end
end
