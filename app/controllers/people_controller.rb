# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class PeopleController < ApplicationController
  include ApplicationHelper

  before_filter :load_person, :only => [:show,
                                        :edit,
                                        :update,
                                        :delete,
                                        :destroy]

  access_control :acl do
    allow :superuser

    actions :index do
      allow :read, :read_person
    end

    actions :new, :create do
      allow :create, :create_person
    end

    actions :edit, :update do
      allow :update, :update_person, :of => :person
    end

    actions :destroy do
      allow :delete, :delete_person, :of => :person
    end
  end

  layout 'dashboard'

  def index
    @people = Person
    if params[:s]
      @people = @people.db_search(params[:s])
    end
    @people = allowed_objs(@people.all, :read)

    render :json => @people
  end

  def show
  end

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
        format.json { render :json => @person.as_json(:root => nil), :location => nil }
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
        format.json { render :json => @person.as_json(:root => nil), :location => nil }
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
