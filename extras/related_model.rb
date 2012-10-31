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

  class Edge
    attr_accessor :source
    attr_accessor :destination
    attr_accessor :type

    def initialize(source, destination, type)
      @source = source
      @destination = destination
      @type = type
    end

    def eql?(other)
      if other.equal?(self)
        return true
      elsif !self.class.equal?(other.class)
        return false
      end

      self.source.eql?(other.source) &&
      self.destination.eql?(other.destination) &&
      self.type.eql?(other.type)
    end
  end

  def related_edges
    # Returns a list of all relationship edges going to/from this node.
    # An edge consists of {:source, :destination, :type}

    # First, normal 'relationships'
    edges = Set.new
    source_relationships.each do |rel|
      edge = Edge.new(self, rel.destination,rel.relationship_type_id)
      edges.add(edge)
    end

    destination_relationships.each do |rel|
      edge = Edge.new(rel.source, self, rel.relationship_type_id)
      edges.add(edge)
    end

    # Next, ObjectPerson
    ops = ObjectPerson.where(:personable_id => self.id,
                             :personable_type => self.class.to_s)

    ops.each do |op|
      edge = Edge.new(op.person, self, "person_#{op.role}_for_#{self.class.to_s.underscore}")
      edges.add(edge)
    end

    if self.methods.include? :custom_edges
      edges.merge(self.custom_edges)
    end

    edges
  end

  def ability_graph(allowed_abilities)
    graph_data = {:objs => Set.new([self]),
                  :edges => Set.new}
    
    allowed_abilities.each do |ability|
      objs = graph_data[:objs].clone
      objs.each do |obj|
        graph_data = obj.ability_graph_recurse(graph_data, ability)
      end
    end

    d3_graph = {
      :nodes => [],
      :links => []
    }

    # Add node data, and create the lookup table of obj => node index
    obj_to_node_id = {}
    graph_data[:objs].each do |obj|
      d3_graph[:nodes].push({
        :type => obj.class.to_s.underscore,
        :node => obj,
        :link => Rails.application.routes.url_helpers.method("flow_#{obj.class.to_s.underscore}_path").call(obj.id)
      })

      obj_to_node_id[obj] = d3_graph[:nodes].length - 1
    end

    graph_data[:edges].each do |edge|
      d3_graph[:links].push({
          :source => obj_to_node_id[edge.source],
          :target => obj_to_node_id[edge.destination],
          :edge => edge
        })
    end

    d3_graph
  end

  def ability_graph_recurse(result_set, ability)
    # Get all related edges
    related_edges.each do |edge|
      # For each related edge

      if result_set[:edges].include? edge
        # If this edge is already in the result set, continue
        next
      end

      # Get the other node
      if edge.source == self
        other = edge.destination
        direction = :forward
      else
        other = edge.source
        direction = :backward
      end

      ability = ability.to_sym

      # Okay, we have an edge with an endpoint that isn't in our set yet.
      # Check to see if it has the right ability
      type = edge.type.to_sym
      edge_abilities = DefaultRelationshipTypes::RELATIONSHIP_ABILITIES[type]

      if !edge_abilities
        #raise "Unknown edge type #{type}"
        puts "Unknown edge type #{type}"
        edge_abilities = DefaultRelationshipTypes::RELATIONSHIP_ABILITIES[:default]
      end

      # Ability :all is a special case used for traversing the entire graph
      ability_directions = edge_abilities[ability]
      if !ability_directions && !ability == :all
        # Does not allow traversal for this ability, continue
        next
      end

      if (ability_directions == :both) || (ability_directions == direction) || (ability == :all)
        # This is a valid edge. Add it
        result_set[:edges].add(edge)

        # Add the other object to the nodes list if it's not already there
        if result_set[:objs].add?(other)
          # Recurse through this node if we just added it
          other.ability_graph_recurse(result_set, ability)
        end
      end
    end
    result_set
  end

  def object_via_ability?(object, ability)
    # Given an ability, see if we can traverse to the given object
    # FIXME: Do an optimized version of this which is faster. Right now,
    # just use the full graph generation and search for the node in it.
    result = ability_graph([ability])
    found_object = result[:nodes].detect do |obj|
      if obj[:node].eql? object
        true
      else
        false
      end
    end

    if found_object.nil?
      false
    else
      true
    end
  end

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
