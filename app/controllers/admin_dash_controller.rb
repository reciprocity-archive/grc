# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Admin dashboard
class AdminDashController < ApplicationController

#  access_control :acl do
#    allow :superuser
#  end
  
  before_filter :check_admin_authorization

  layout 'dashboard'

  def index
    @accounts = allowed_objs(Account.all, :read)
    @people = allowed_objs(Person.all, :read)
    @root_categories = allowed_objs(Category.roots, :read)
    @options = allowed_objs(Option.all, :read)
  end

  def sre
  end

  def show_by_option
    if params[:title].present?
      option = Option.find_by_title(params[:title])
    else
      option = Option.find(params[:id])
    end

    raise "not found" unless option

    res = []
    all_models do |model|
      model.reflect_on_all_associations.each do |assoc|
        if assoc.class_name == "Option"
          model.joins(assoc.name).where(:options => {:id => option.id}).each do |o|
            res << [model.name, o.id, assoc.name]
          end
        end
      end
    end

    render :json => res
  end

  def show_by_category
    if params[:title].present?
      category = Category.find_by_title(params[:title])
    else
      category = Category.find(params[:id])
    end

    raise "not found" unless category

    res = Categorization.where(:category_id => category.id).map do |c| 
      [c.categorizable_type, c.categorizable_id]
    end
    render :json => res
  end

  def show_by_relationship_type
    relationship_type = params[:title]

    res = Relationship.where(:relationship_type_id => relationship_type).map do |r|
      [r.source_type, r.source_id, r.destination_type, r.destination_id]
    end
    
    render :json => res
  end

  def show_bad_relationships
    types = DefaultRelationshipTypes.types.keys
    res = Relationship.where('relationship_type_id NOT IN (?)', types).map do |r|
      [r.id, r.relationship_type_id, r.source_type, r.source_id, r.destination_type, r.destination_id]
    end

    render :json => res
  end

  def show_strict_bad_relationships
    rel_types = DefaultRelationshipTypes.types

    res = Relationship.includes(:source, :destination).all.map do |rel|
      rel_type = rel_types[rel.relationship_type_id]
      errors = []
      if !rel_type
        errors.append("relationship_type_id invalid")
      else
        if rel_type["source_type"] != rel.source_type
          errors.append("source_type mismatch: expected #{rel_type["source_type"]}, got: #{rel.source_type}")
        end
        if rel_type["target_type"] != rel.destination_type
          errors.append("destination_type mismatch: expected #{rel_type["target_type"]}, got: #{rel.destination_type}")
        end
      end
      if rel.source.nil?
        errors.append("source doesn't exist")
      end
      if rel.destination.nil?
        errors.append("destination doesn't exist")
      end
      if errors.size > 0
        { :errors => errors, :relationship => rel.as_json }
      end
    end.compact

    render :json => res
  end

  def show_bad_belongs_to
    res = []
    all_models do |model|
      model.reflect_on_all_associations.each do |assoc|
        next if assoc.name == :relationship_type
        next if model.name == 'Help' && assoc.name == :modified_by
        next if model.name == 'ControlAssessment' && assoc.name == :modified_by
        if assoc.macro == :belongs_to
          if !assoc.options[:polymorphic]
            model.includes(assoc.name).where(["#{model.table_name}.#{assoc.name}_id IS NOT NULL AND #{assoc.table_name}.id IS NULL"]).each do |o|
              res << [model.name, o.id, assoc.name]
            end
          else
            model.includes(assoc.name).each do |o|
              if o.send(assoc.name) == nil
                res << [model.name, o.id, assoc.name]
              end
            end
          end
        end
      end
    end
    render :json => res
  end
end
