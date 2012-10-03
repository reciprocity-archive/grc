# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class PeopleController < ApplicationController
  include ApplicationHelper

  before_filter :load_person, :only => [:edit,
                                        :update,
                                        :delete,
                                        :destroy]

  access_control :acl do
    allow :superuser

    actions :new, :create do
      allow :create, :create_person
    end

    actions :list do
      allow :read, :read_person
    end

    actions :list_update, :list_edit do
      allow :update, :update_person
    end

    actions :edit, :update do
      allow :update, :update_person, :of => :person
    end

    actions :destroy do
      allow :delete, :delete_person, :of => :person
    end
  end

  layout 'dashboard'

  def new
    @person = Person.new(person_params)

    render :layout => nil
  end

  def edit
    render :layout => nil
  end

  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        flash[:notice] = "Successfully created a new person."
        format.json { render :json => @person.as_json(:root => nil) }
        format.html { ajax_refresh }
      else
        flash[:error] = @person.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    respond_to do |format|
      if @person.authored_update(current_user, person_params)
        flash[:notice] = "Successfully updated the person."
        format.html { ajax_refresh }
      else
        flash[:error] = @person.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def delete
    @model_stats = []
    @relationship_stats = []
    @relationship_stats << [ 'Object', @person.object_people.count ]

    respond_to do |format|
      format.json { render :json => @person.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @person, :url => flow_person_path(@person), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @person.destroy
    flash[:notice] = "Person deleted"
    respond_to do |format|
      format.html { redirect_to programs_dash_path }
      format.json { render :json => @person.as_json(:root => nil) }
    end
  end

  def list
    @people = Person.where({})
    if params[:s] && !params[:s].blank?
      @people = @people.where(:name => params[:s])
    end
    respond_to do |format|
      format.html { render :layout => nil }
      format.json do
        render :json => @people.as_json(:root => nil)
      end
    end
  end

  def list_edit
    if !params[:object_type] || !params[:object_id]
      return 400
    end

    @object = params[:object_type].classify.constantize.find(params[:object_id])
    #@people = Person.where({})
    render :layout => nil
  end

  def list_update
    if !params[:object_type] || !params[:object_id]
      return 400
    end

    @object = params[:object_type].classify.constantize.find(params[:object_id])

    new_object_people = []

    if params[:items]
      params[:items].each do |_, item|
        object_person = @object.object_people.where(:person_id => item[:id]).first
        if !object_person
          object_person = @object.object_people.new({:person_id => item[:id]}, :without_protection => true)
        end
        object_person.role = item[:role].blank? ? nil : item[:role]
        if !object_person.new_record?
          object_person.save
        end
        new_object_people.push(object_person)
      end
    end

    @object.object_people = new_object_people

    respond_to do |format|
      if @object.save
        format.json do
          render :json => @object.object_people.all.map { |op| op.as_json_with_role_and_person(:root => nil) }
        end
        format.html
      else
        flash[:error] = "Could not update associated people"
        format.html { render :layout => nil }
      end
    end
  end

  private
    def load_person
      @person = Person.find(params[:id])
    end

    def person_params
      person_params = params[:person] || {}
      language_id = person_params.delete(:language_id)
      if language_id
        language = Option.where(:role => 'person_language', :id => language_id).first
        if language
          person_params[:language] = language
        end
      end
      person_params
    end
end
