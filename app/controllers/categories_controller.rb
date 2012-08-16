# Author:: Daniel Ring (mailto:danring+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class CategoriesController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin
  end

  layout 'dashboard'

  def list_edit
    @object = params[:object_type].classify.constantize.find(params[:object_id])
    #@people = Person.where({})
    render :layout => nil
  end

  def list_update
    @object = params[:object_type].classify.constantize.find(params[:object_id])

    new_categorizations = []

    if params[:items]
      params[:items].each do |_, item|
        categorization = @object.categorizations.where(:category_id => item[:id]).first
        if !categorization
          categorization = @object.categorizations.new(:category_id => item[:id])
        end
        new_categorizations.push(categorization)
      end
    end

    @object.categorizations = new_categorizations

    respond_to do |format|
      if @object.save
        format.json do
          render :json => @object.categorizations.all.map { |cat| cat.as_json(:root => nil, :include => { :category => { :methods => :parent_name }}) }
        end
        format.html
      else
        flash[:error] = "Could not update categorizations"
        format.html { render :layout => nil }
      end
    end
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
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        flash[:notice] = "Successfully created a new category."
        format.json { render :json => @category.as_json(:root => nil) }
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
        format.html { ajax_refresh }
      else
        flash[:error] = @category.errors.full_messages
        format.html { render :layout => nil, :status => 400 }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy
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

