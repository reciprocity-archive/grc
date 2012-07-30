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
        @people.include_root_in_json = false
        render :json => @people
      end
    end
  end

  def list_form
    @object = params[:object_type].classify.constantize.find(params[:object_id])
    @people = Person.where({})
    render :layout => nil
  end

  def list_save
    @object = params[:object_type].classify.constantize.find(params[:object_id])
    @object.people.clear

    params[:items].each do |_, item|
      person = Person.find(item[:id])
      role = item[:role] == 'none' ? nil : item[:role]
      @object.object_people << ObjectPerson.new(:person => person, :role => role)
    end

    @object.object_people.include_root_in_json = false
    render :json => @object.object_people.all.map(&:as_json_with_role_and_person)
  end

  def new
    @person = Person.new(params[:person])

    render :layout => nil
  end

  def edit
    @person = Person.find(params[:id])

    render :layout => nil
  end

  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
        flash[:notice] = "Successfully created a new person."
        format.json { @person.include_root_in_json = false; render :json => @person }
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
      if @person.authored_update(current_user, params[:person])
        flash[:notice] = "Successfully updated the person."
        format.html { ajax_refresh }
      else
        flash[:error] = @person.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end
end
