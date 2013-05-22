class CategorizationsController < BaseMappingsController

#  access_control :acl do
#    allow :superuser
#  end

  def index
    @objects = Categorization
    if params[:object_id].present?
      @objects = @objects.where(
        :categorizable_type => params[:object_type],
        :categorizable_id => params[:object_id])
    end
    if params[:scope_id].present?
      @objects = @objects.joins(:category).where(
        :categories => { :scope_id => params[:scope_id] })
    end
    render :json => @objects,
      :include => { :category => { :methods => :parent_name } }
  end

  private

    def list_edit_context
      super.merge \
        :form_url => url_for(:action => :create, :only_path => true)
    end

    def list_form_context
      super.merge \
        :object => params[:object_type].constantize.find(params[:object_id]),
        :scope_id => params[:scope_id]
    end

    def update_object(relation, object_params)
      relation.category = Category.find(object_params[:category_id])
      related_object = object_params[:categorizable_type].constantize.find(object_params[:categorizable_id])
      relation.categorizable = related_object
    end

    def default_as_json_options
      { :include => { :category => { :methods => :parent_name } } }
    end
end
