# Author:: Daniel Ring (mailto:danring+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class CategoriesController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser
  end

  layout 'dashboard'

  def index
    @categories = Category.where(Category.arel_table[:parent_id].not_eq(nil))
    if params[:s]
      @categories = @categories.db_search(params[:s])
    end
    render :json => @categories.all.as_json
  end

  def new
    @category = Category.new(category_params)

    render :layout => nil
  end

  def edit
    @category = Category.find(params[:id])

    render :layout => nil
  end

  def create
    # Ctype needs to be set to something, default to CATEGORY_TYPE_ID as it's the only type we have right now.
    ccats = Category.ctype(Control::CATEGORY_TYPE_ID)
    @category = ccats.new(category_params)

    respond_to do |format|
      if @category.save
        flash[:notice] = "Successfully created a new category."
        format.json { render :json => @category.as_json(:root => nil), :location => nil }
        format.html { ajax_refresh }
      else
        flash[:error] = @category.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.authored_update(current_user, category_params)
        flash[:notice] = "Successfully updated the category."
        format.json { render :json => @category.as_json(:root => nil), :location => nil }
        format.html { ajax_refresh }
      else
        flash[:error] = @category.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def delete
    @category = Category.find(params[:id])
    @model_stats = []
    @relationship_stats = []

    respond_to do |format|
      format.json { render :json => @category.as_json(:root => nil) }
      format.html do
        render :layout => nil, :template => 'shared/delete_confirm',
          :locals => { :model => @category, :url => flow_category_path(@category), :models => @model_stats, :relationships => @relationship_stats }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    flash[:notice] = "Category deleted"
    respond_to do |format|
      format.html { redirect_to programs_dash_path }
      format.json { render :json => @category.as_json(:root => nil) }
    end
  end

  private

    def category_params
      category_params = params[:category] || {}
      parent_id = category_params.delete(:parent_id)
      if parent_id
        category_params[:parent] = Category.find(parent_id)
      end
      category_params
    end
end
