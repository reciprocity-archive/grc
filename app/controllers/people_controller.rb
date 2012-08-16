# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class PeopleController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin
  end

  layout 'dashboard'

  def tooltip
    @person = Person.find(params[:id])
    render :layout => nil
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
    @object = params[:object_type].classify.constantize.find(params[:object_id])
    #@people = Person.where({})
    render :layout => nil
  end

  def list_update
    @object = params[:object_type].classify.constantize.find(params[:object_id])

    new_object_people = []

    if params[:items]
      params[:items].each do |_, item|
        object_person = @object.object_people.where(:person_id => item[:id]).first
        if !object_person
          object_person = @object.object_people.new(:person_id => item[:id])
        end
        object_person.role = item[:role].blank? ? nil : item[:role]
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

  def new
    @person = Person.new(person_params)

    render :layout => nil
  end

  def edit
    @person = Person.find(params[:id])

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
    @person = Person.find(params[:id])

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

  def destroy
    @person = Person.find(params[:id])
    @person.destroy
  end

  private

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
