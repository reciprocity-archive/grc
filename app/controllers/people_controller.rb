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

  def new
    @person = Person.new(params[:section])

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
        format.html { ajax_refresh }
      else
        flash[:error] = @person.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @person = Person.new(params[:id])

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
