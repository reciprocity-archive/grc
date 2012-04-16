class NavigationController < ApplicationController
  include ApplicationHelper

  access_control :acl do
    allow :superuser, :admin, :analyst
  end

  def control_hierarchy
    unless session[:regulation_id]
      render :json => []
      return
    end

    control_map = {}
    Control.where(:regulation_id => session[:regulation_id]).each do |c|
      c.control_objectives.each do |co|
        control_map[co.id] ||= []
        control_map[co.id] << { :type => 'c', :label => c.title, :slug => c.slug, :id => c.id }
      end
    end

    cos = ControlObjective.where(:regulation_id => session[:regulation_id]).map do |co|
      { :type => 'co', :label => co.title, :slug => co.slug, :id => co.id, :children => control_map[co.id] || [] }
    end

    render :json => cos
  end
end
