class ObjectPeopleController < BaseMappingsController

#  access_control :acl do
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_object_person
#    end
#
#    actions :create do
#      allow :create, :create_object_person
#    end
#
#    actions :list_edit, :create do
#      allow :update, :update_object_person
#    end
#  end

  def index
    @object_people = ObjectPerson
    if params[:object_id].present?
      @object_people = @object_people.where(
        :personable_type => params[:object_type],
        :personable_id => params[:object_id])
    end
    @object_people = allowed_objs(@object_people.all, :read)

    render :json => @object_people, :include => :person
  end

  private

    def list_edit_context
      super.merge \
        :form_url => url_for(:action => :create, :only_path => true)
    end

    def list_form_context
      super.merge \
        :object => params[:object_type].constantize.find(params[:object_id])
    end

    def update_object(relation, object_params)
      relation.person = Person.find(object_params[:person_id])
      related_object = object_params[:personable_type].constantize.find(object_params[:personable_id])
      relation.personable = related_object

      relation.role = object_params[:role].blank? ? nil : object_params[:role]

      parse_date_param(object_params, :start_date)
      relation.start_date = object_params[:start_date]
      parse_date_param(object_params, :stop_date)
      relation.stop_date = object_params[:stop_date]
    end

    def default_as_json_options
      { :include => :person }
    end
end
