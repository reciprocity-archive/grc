# RelatedModel mixin
#
# Creates some useful scoping functions that allow you to
# create scopes for relationships with very little code. Example usage:
#
# In your model:
# include RelatedModel
#
# scope managed_by, lambda {|object|
#   related_to_source(object, 'manager_of')}
# }
#
module RelatedModel
  def self.included(model)
    model.class_eval do
      has_many :source_relationships, :as => :source, :class_name =>'Relationship', :dependent => :destroy
      has_many :destination_relationships, :as => :destination, :class_name => 'Relationship', :dependent => :destroy
    end
    model.extend(ClassMethods)
  end

  def related_edges
    # Returns a list of all relationship edges going to/from this node.
    # An edge consists of {:source, :destination, :type}

    # First, normal 'relationships'
    edges = []
    source_relationships.each do |rel|
      edge = {
        :source => self,
        :destination => rel.destination,
        :type => rel.relationship_type_id
      }
      edges.push(edge)
    end

    destination_relationships.each do |rel|
      edge = {
        :source => rel.source,
        :destination => self,
        :type => rel.relationship_type_id
      }
      edges.push(edge)
    end

    # Next, ObjectPerson
    ops = ObjectPerson.where(:personable_id => self.id,
                             :personable_type => self.class.to_s)

    ops.each do |op|
      edge = {
        :source => op.person,
        :destination => self,
        :type => "person_#{op.role}_of_#{self.class.to_s.underscore}"
      }
      edges.push(edge)
    end

    if self.methods.include? :custom_edges
      edges.concat(self.custom_edges)
    end

    edges
  end

  def traverse_related_ability(ability)
    traverse_related do |edge, direction|
      type = edge[:type].to_sym
      ability = ability.to_sym
      puts "#{edge.inspect},#{direction}, #{ability}"
      abilities = DefaultRelationshipTypes::RELATIONSHIP_ABILITIES[type]
      if !abilities
        abilities = DefaultRelationshipTypes::RELATIONSHIP_ABILITIES[:default]
      end

      traverse = false
      if abilities[ability]
        if (abilities[ability] == :both) || (direction == abilities[ability])
          traverse = true
        end
      end
      traverse
    end
  end

  def traverse_related(direction = :both, &block)
    # Traverse all relationships from an object.
    # Use the block passed in to determine whether you are allowed to traverse
    # to that object. If so, add that object to the result set and recurse.
    # Once done, return the set of all objects visited.

    def make_node(obj)
      {
        :type => obj.class.to_s.underscore,
        :node => obj,
        :link => Rails.application.routes.url_helpers.method("flow_#{obj.class.to_s.underscore}_path").call(obj.id)
      }
    end

    # Collect all relationships including this object
    objs = Set.new([self])
    nodes = [make_node(self)]
    obj_to_node_id = {
      self => 0
    }
    links = []


    result_set = Set.new([self])

    while objs.length > 0 do
      new_objs = Set.new
      objs.each do |obj|
        edges = obj.related_edges
        edges.each do |edge|
          if (edge[:source] == obj) && ([:forward, :both].include? direction)
            if !block_given? || yield(edge, :forward)
              if result_set.add?(edge[:destination])
                new_objs.add(edge[:destination])
                nodes.push(make_node(edge[:destination]))
                obj_to_node_id[edge[:destination]] = nodes.length - 1
                links.push({
                  :source => obj_to_node_id[edge[:source]],
                  :target => obj_to_node_id[edge[:destination]],
                  :edge => edge
                })
              end
            end
          elsif (edge[:destination] == obj) && ([:backward, :both].include? direction)
            if !block_given? || yield(edge, :backward)
              if result_set.add?(edge[:source])
                new_objs.add(edge[:source])
                nodes.push(make_node(edge[:source]))
                obj_to_node_id[edge[:source]] = nodes.length - 1
                links.push({
                    :source => obj_to_node_id[edge[:source]],
                    :target => obj_to_node_id[edge[:destination]],
                    :edge => edge
                  })
              end
            end
          end
        end
      end
      objs = new_objs
    end
    
    return {
      :nodes => nodes,
      :links => links
    }
  end

  #def traverse_related(direction = :both, &block)
  #  # Traverse all relationships from an object.
  #  # Use the block passed in to determine whether you are allowed to traverse
  #  # to that object. If so, add that object to the result set and recurse.
  #  # Once done, return the set of all objects visited.
  #
  #  # Collect all relationships including this object
  #
  #  objs = Set.new([self])
  #
  #  result_set = Set.new
  #
  #  while objs.length > 0 do
  #    new_objs = Set.new
  #    objs.each do |obj|
  #      if [:forward, :both].include? direction
  #        obj.source_relationships.each do |rel|
  #          if !block_given? || yield(rel, rel.destination, :destination)
  #            if result_set.add?(rel.destination)
  #              new_objs.add(rel.destination)
  #            end
  #          end
  #        end
  #      end
  #
  #      if [:backward, :both].include? direction
  #        obj.destination_relationships.each do |rel|
  #          if !block_given? || yield(rel, rel.source, :source)
  #            if result_set.add?(rel.source)
  #              new_objs.add(rel.source)
  #            end
  #          end
  #        end
  #      end
  #    end
  #    objs = new_objs
  #  end
  #  return result_set
  #end

  module ClassMethods
    def related_to_source(object, relationship_type_id)
      object_type = object.class.to_s
      object_id = object.id
      joins(:destination_relationships).where(:relationships => {
        :source_id => object_id,
        :source_type => object_type,
        :relationship_type_id => relationship_type_id
      })
    end

    def related_to_destination(relationship_type_id, object)
      object_type = object.class.to_s
      object_id = object.id
      joins(:source_relationships).where(:relationships => {
        :destination_id => object_id,
        :destination_type => object_type,
        :relationship_type_id => relationship_type_id
      })
    end

    def valid_relationships
      @valid_relationships
    end

    def related_models
      @valid_relationships.reduce(Set.new) do |models, vr|
        models.add(vr[:related_model])
      end
    end
  end
end
