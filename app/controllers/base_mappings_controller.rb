class BaseMappingsController < ApplicationController
  include ApplicationHelper

  def create
    if params[:items].present?
      errors, objects = {}, {}
      model_class.transaction do
        params[:items].keys.each do |id|
          item_errors, item_object = create_or_update_object(params[:items][id])
          errors[id] = item_errors if item_errors
          objects[id] = item_object
        end
      end
      if errors.empty?
        render :json => create_objects_as_json(objects.values.compact), :status => 200
      else
        render :json => { :errors => errors, :objects => create_objects_as_json(objects) }, :status => 400
      end
    elsif params[object_name]
      model_class.transaction do
        errors, object = create_or_update_object(params[object_name])
      end
      if errors.nil? || errors.empty?
        render :json => create_object_as_json(object) || {}, :status => 200
      else
        render :json => { :errors => errors }, :status => 400
      end
    else
      render :json => {}, :status => 200
    end
  end

  def update
    params[object_name][:id] = params[:id]
    model_class.transaction do
      errors, object = create_or_update_object(params[object_name])
    end
    if errors.nil? || errors.empty?
      render :json => update_object_as_json(object) || {}, :status => 200
    else
      render :json => { :errors => errors }, :status => 400
    end
  end

  def list_edit
    respond_to do |format|
      format.html do
        render :layout => nil, :locals => list_edit_context
      end
    end
  end

  def destroy
    object = model_class.find(params[:id])
    object.destroy

    render :text => ''
  end

  private

    def list_edit_context
      { :model_name => model_name,
        :form_url => url_for(:action => :create, :only_path => true),
        :form_context => list_form_context,
      }
    end

    def list_form_context
      {}
    end

    def object_name
      model_name.underscore
    end

    def model_name
      self.class.name.sub('Controller', '').singularize
    end

    def model_class
      model_name.constantize
    end

    def object_params(object_params=nil)
      object_params || params || HashWithIndifferentAccess.new
    end

    def create_or_update_object(params)
      params ||= HashWithIndifferentAccess.new

      if params[:id].present? && params[:_destroy] == 'destroy'
        object = model_class.find(params[:id])
        object.destroy
        [nil, nil]
      else
        if params[:id].present?
          object = model_class.find(params[:id])
        else
          object = model_class.new
        end

        update_object(object, params)

        if object.save
          [nil, object]
        else
          [object.errors.messages, object]
        end
      end
    end

    def update_object(object, params)
      object.update_attributes(object_params(params))
    end

    def default_as_json_options
      {}
    end

    def objects_as_json(objects, args=nil)
      objects.as_json(default_as_json_options.merge(args || {}))
    end

    def object_as_json(object, args=nil)
      object.as_json(default_as_json_options.merge(args || {}))
    end

    def create_objects_as_json(objects)
      objects_as_json(objects)
    end

    def create_object_as_json(object)
      object_as_json(object)
    end

    def update_object_as_json(object)
      object_as_json(object)
    end
end
