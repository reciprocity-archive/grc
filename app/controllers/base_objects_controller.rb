class BaseObjectsController < ApplicationController
  include ApplicationHelper

  before_filter :load_object,
    :only => [ :show, :edit, :update, :delete, :destroy, :tooltip]

  def index
    object_set = model_class
    if params[:s].present?
      if object_set.respond_to?(:fulltext_search)
        object_set = object_set.fulltext_search(params[:s])
      else
        object_set = object_set.db_search(params[:s])
      end
    end
    object_set = allowed_objs(object_set.all, :read)
    set_objects(object_set)

    respond_to do |format|
      format.html do
        if params[:quick]
          render :partial => 'quick', :locals => { :quick_result => params[:qr] }
        end
      end
      format.json do
        render :json => objects_as_json
      end
    end
  end

  def show
    show_set_page_types

    respond_to do |format|
      format.html do
        render :locals => show_context
      end
      format.json do
        render :json => show_object_as_json
      end
    end
  end

  def new
    set_object(new_object)
    update_object

    respond_to do |format|
      format.html do
        render :layout => nil, :locals => new_context
      end
    end
  end

  def edit
    update_object

    respond_to do |format|
      format.html do
        render :layout => nil, :locals => edit_context
      end
    end
  end

  def create
    set_object(new_object)

    respond_to do |format|
      if update_and_save_object
        location = post_create_path

        flash[:notice] = create_success_message
        format.json do
          render :json => create_object_as_json, :location => location
        end
        format.html do
          redirect_to location
        end
      else
        flash[:error] = create_error_message
        format.html do
          render :layout => nil, :status => 400, :locals => create_context
        end
        format.json do
          render :json => create_errors_as_json, :status => 400
        end
      end
    end
  end

  def update
    respond_to do |format|
      if update_and_save_object
        location = post_update_path

        flash[:notice] = update_success_message
        format.json do
          render :json => update_object_as_json, :location => location
        end
        format.html do
          redirect_to location
        end
      else
        flash[:error] = update_error_message
        format.html do
          render :layout => nil, :status => 400, :locals => update_context
        end
        format.json do
          render :json => update_errors_as_json, :status => 400
        end
      end
    end
  end

  def delete
    respond_to do |format|
      location = delete_path

      format.json do
        render :json => delete_object_as_json, :location => location
      end
      format.html do
        render \
          :template => 'shared/delete_confirm',
          :layout => nil,
          :locals => delete_context
      end
    end
  end

  def destroy
    object.destroy

    flash[:notice] = destroy_success_message

    respond_to do |format|
      location = post_destroy_path

      format.html do
        redirect_to location
      end
      format.json do
        render :json => destroy_object_as_json, :location => location
      end
    end
  end

  def tooltip
    render :layout => '_tooltip', :locals => { object_name.to_sym => object }
  end

  def new_object_title
    object_name.titleize
  end

  def new_object_path
    url_for(:action => :new, :only_path => true) if respond_to?(:new)
  end

  private

    def show_set_page_types
      @page_type = object_name.pluralize
    end

    def show_context
      {}
    end

    def new_context
      { :object => object,
        :form_url => url_for(:action => :create, :only_path => true),
        :form_context => new_form_context,
      }
    end

    def edit_context
      { :object => object,
        :form_url => url_for(:action => :update, :id => object.id, :only_path => true),
        :form_context => edit_form_context,
      }
    end

    def create_context
      { :object => object,
        :form_context => create_form_context
      }
    end

    def update_context
      { :object => object,
        :form_context => update_form_context
      }
    end

    def delete_context
      { :model => object,
        :url => delete_path,
        :models => delete_model_stats,
        :relationships => delete_relationship_stats
      }
    end

    def base_form_context
      {}
    end

    def new_form_context
      base_form_context
    end

    def edit_form_context
      base_form_context
    end

    def create_form_context
      base_form_context
    end

    def update_form_context
      base_form_context
    end

    def create_success_message
      "Successfully created a new #{object_words}"
    end

    def create_error_message
      "There was an error creating the #{object_words}."
    end

    def update_success_message
      "Successfully updated the #{object_words}."
    end

    def update_error_message
      "There was an error updating the #{object_words}."
    end

    def destroy_success_message
      "#{object_words.capitalize} deleted"
    end

    def object_path
      url_for(:action => :show, :id => object.id, :only_path => true)
    end

    def post_create_path
      object_path
    end

    def post_update_path
      object_path
    end

    def delete_path
      url_for(:action => :destroy, :id => object.id, :only_path => true)
    end

    def post_destroy_path
      programs_dash_path
    end

    def new_object
      model_name.constantize.new
    end

    def set_objects(value)
      instance_variable_set('@' + object_name.pluralize, value)
    end

    def objects
      instance_variable_get('@' + object_name.pluralize)
    end

    def objects_as_json
      objects.as_json
    end

    def set_object(value)
      instance_variable_set('@' + object_name, value)
    end

    def object
      instance_variable_get('@' + object_name)
    end

    def object_as_json(args=nil)
      object.as_json({:root => nil}.merge(args || {}))
    end

    def show_object_as_json(args=nil)
      object_as_json(args)
    end

    def create_object_as_json(args=nil)
      object_as_json(args)
    end

    def update_object_as_json(args=nil)
      object_as_json(args)
    end

    def delete_object_as_json(args=nil)
      object_as_json(args)
    end

    def destroy_object_as_json(args=nil)
      object_as_json(args)
    end

    def errors_as_json
      { :errors => object.errors.messages }
    end

    def create_errors_as_json
      errors_as_json
    end

    def update_errors_as_json
      errors_as_json
    end

    def load_object
      set_object(model_name.constantize.find(params[:id]))
    end

    def model_name
      send(:class).name.sub('Controller', '').singularize
    end

    def model_class
      model_name.constantize
    end

    def object_name
      model_name.underscore
    end

    def object_words
      object_name.titleize.downcase
    end

    def object_params
      params_name = "#{object_name}_params".to_sym
      if respond_to?(params_name, include_private=true)
        send(params_name)
      else
        params[object_name] || HashWithIndifferentAccess.new
      end
    end

    def update_object(params=nil)
      object.assign_attributes(params || object_params)
    end

    def save_object
      object.save
    end

    def update_and_save_object
      params = object_params
      update_object(params)
      object.authored_update(current_user, params)
    end

    def delete_model_stats
      []
    end

    def extra_delete_relationship_stats
      []
    end

    def delete_relationship_stats
      objects =
        common_delete_relationship_stats.to_a +
        extra_delete_relationship_stats.to_a

      objects.group_by(&:first).map do |object_type, instances|
        count = instances.map(&:second).map do |objs|
          if objs.kind_of?(Array)
            objs.flatten.size
          elsif objs.kind_of?(Fixnum)
            objs
          else
            1 # Don't know what this object is
          end
        end.sum
        [ object_type, count ]
      end
    end

    def common_delete_relationship_stats
      # People
      object_people = ObjectPerson.
        where(
          :personable_type => object.class.name,
          :personable_id => object.id)

      # Documents
      object_documents = ObjectDocument.
        where(
          :documentable_type => object.class.name,
          :documentable_id => object.id)

      categorizations = Categorization.
        where(
          :categorizable_type => object.class.name,
          :categorizable_id => object.id)

      # Relationships
      [ [ 'Person', object_people.count ],
        [ 'Document', object_documents.count ],
        [ 'Category', categorizations.count ]
      ] + Relationship.related_objects_for_delete(object).to_a
    end

    def self.no_base_action(*actions)
      actions.each do |method|
        define_method method do
          raise AbstractController::ActionNotFound, "The action '#{action_name}' could not be found for #{self.class.name}"
        end
      end
    end
end

