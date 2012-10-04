class ObjectPeopleController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser
  end

  def index
    @objects = ObjectPerson.where(:personable_type => params[:object_type], :personable_id => params[:object_id])
    render :json => @objects, :include => :person
  end

  def create
    
  end

  private

    def object_people_params
      params
    end

end
