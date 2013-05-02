# RelatedModel mixin
#
# Many mixins that exist for managing relationships, and especially the relationship
# traversal functions that are used in the context of authorization.
#
# Also creates some useful scoping functions that allow you to
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
  @relatable_models = nil

  def self.included(model)
    model.class_eval do
      has_many :source_relationships, :as => :source, :class_name =>'Relationship', :dependent => :destroy
      has_many :destination_relationships, :as => :destination, :class_name => 'Relationship', :dependent => :destroy
    end
    model.extend(ClassMethods)

    if model.ancestors.include?(ActiveRecord::Base)
      @relatable_models = [] if @relatable_models.nil?
      @relatable_models.push(model)
    end
  end

  def self.relatable_models
    @relatable_models
  end

  class Edge
    # Simple utility class that allows me to use edges in Sets. Specifically,
    # Has an eql? function for that purpose.
    #
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

    # Next, ObjectPerson relationships - these are common enough that
    # we look for them here instead of in custom_edges
    ops = ObjectPerson.where(:personable_id => self.id,
                             :personable_type => self.class.to_s)

    ops.each do |op|
      edge = Edge.new(op.person, self, "person_#{op.role}_for_#{self.class.to_s.underscore}")
      edges.add(edge)
    end

    # Include non-standard edge types via the custom_edges method of the
    # model if it is implemented - generally, those that are hardcoded
    # into the schema.
    if self.respond_to? :custom_edges
      edges.merge(self.custom_edges)
    end

    edges
  end

  # Handy timer class used when performance optimizing.
  class Timer
    def initialize
      @start = DateTime.now.to_f
    end

    def delta
      DateTime.now.to_f - @start
    end
  end

  def ability_graph(allowed_abilities)
    # Generates a graph of nodes and edges that can be traversed from this
    # node using the list of allowed abilities.
    # The allowed_abilities list applies the abilities in order.
    # e.g. if you pass in [:read, :meta_read], it gets the graph for the
    # :read ability first, then, for each nodes reachable via :read, includes the
    # graph reachable via the :meta_read ability

    # This is the recursive version. Commented out
    # in deference to the (generally faster) non-recursive version.
    #graph_data = {:objs => Set.new([self]),
    #              :edges => Set.new}
    #
    #allowed_abilities.each do |ability|
    #  objs = graph_data[:objs].clone
    #  objs.each do |obj|
    #    graph_data = obj.ability_graph_recurse(graph_data, ability)
    #  end
    #end
    #

    objs = Set.new([self])
    edges = Set.new

    # FIXME: Optimize this so we're not generating the full graph that's used to
    # generate the ability graph each time, this can be REALLY slow, especially in
    # the case of multiple abilities, where we're generating it for each node
    # in the first ability's result set.
    allowed_abilities.each do |ability|
      cur_objs = objs.clone
      cur_objs.each do |obj|
        result = obj.ability_graph_preload(ability) # Uses "preload" version which gets full graph first.
        objs.merge(result[:objs])
        edges.merge(result[:edges])
      end
    end

    {
      :objs => objs,
      :edges => edges
    }
  end

  def ability_graph_preload(ability)
    # Generate the ability graph by preloading the entire graph, and then
    # doing a filtered traverse. Should be faster due to the reduced number of queries.
    objs = Set.new
    edges = Set.new

    # Get a list of all models that we want to use as nodes
    # Hack - get a list of all tables, then delete the ones we don't
    # care.
    models = ActiveRecord::Base.connection.tables.map {|t| t.camelcase.singularize}
    models.delete("SchemaMigration")

    # ObjectPerson is weird - it's a related_model, but isn't valid here.
    # I don't remember why I made it a related model.
    models.delete("ObjectPerson")
    models = models.map {|m| m.constantize}

    models.each do |model|
      if model.respond_to? :all_related_edges
        new_edges = model.all_related_edges
        new_objs = model.all
        objs.merge(new_objs)
        edges.merge(new_edges)
      end
    end

    # Now that we have all nodes/edges, we need to make the graph
    # traversable so we can generate the subtree for this object
    graph = {}

    # Initialize the graph with one per object
    objs.each do |obj|
      graph[obj] = Set.new
    end

    edges.each do |edge|
      # Add the edges
      graph[edge.source].add(edge)
      graph[edge.destination].add(edge)
    end

    # Now we have a traversable data structure. Look up this node
    # in the data structure and walk the tree, adding nodes and edges
    # we find to the result set.
    objs = Set.new
    edges = Set.new

    new_objs = [self]
    while new_objs.length > 0
      obj = new_objs.pop
      if !objs.add(obj)
        next
      end

      graph[obj].each do |edge|
        if (traverse_edge?(obj, edge, ability))
          if edges.add?(edge)
            if edge.source != obj
              new_objs.push(edge.source)
            else
              new_objs.push(edge.destination)
            end
          end
        end
      end
    end

    {
      :objs => objs,
      :edges => edges
    }
  end

  def traverse_edge?(obj, edge, ability, traverse_forward = true)
    # Determine if we are allowed to traverse this edge, given the provided ability.

    # If we are not traversing forward, we want to look in the opposite direction in the lookup table
    # from the direction we are traversing. This is for the object_via_ability_fast
    # traversal.

    # Get the other node
    if edge.source == obj
      other = edge.destination
      if traverse_forward
        direction = :forward
      else
        direction = :backward
      end
    else
      other = edge.source
      if traverse_forward
        direction = :backward
      else
        direction = :forward
      end
    end

    ability = ability.to_sym

    # Look up the abilities associated with this relationship type.
    type = edge.type.to_sym
    edge_abilities = DefaultRelationshipTypes::RELATIONSHIP_ABILITIES[type]

    if !edge_abilities
      # Unknown ability types are generally bad, as this means that the edge
      # won't be traversed, ever.
      #raise "Unknown edge type #{type}"
      puts "Unknown edge type #{type}"
      edge_abilities = DefaultRelationshipTypes::RELATIONSHIP_ABILITIES[:default]
    end

    if ability == :all
      return true
    end

    # Bail if we don't have the ability listed at all.
    ability_directions = edge_abilities[ability]
    if !ability_directions
      # Does not allow traversal for this ability, continue
      return false
    end

    # Return true if we match traversal directions in the lookup table.
    if (ability_directions == :both) || (ability_directions == direction)
      return true
    end
    return false
  end

  def ability_graph_recurse(result_set, ability)
    # Get all related edges
    related_edges.each do |edge|
      # For each related edge

      if result_set[:edges].include? edge
        # If this edge is already in the result set, continue
        next
      end

      if traverse_edge?(self, edge, ability)
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
    result[:objs].include?(object)
  end

  def objects_via_ability(objects, ability)
    # Return the subset of these objects that can be reached via
    # the ability graph for this ability.

    graph = ability_graph_preload(ability)

    objects.reduce([]) do |filtered, object|
      # See if the object is in the resulting nodes
      if graph[:objs].include?(object)
        filtered.append(object)
      end
      filtered
    end
  end

  def has_valid_relationship?(type)
    self.class.has_valid_relationship?(type)
  end
  
  def count_destination_objects(destination_model)
    object_type = self.class.to_s
    object_id   = self.id
    Relationship.where(
      source_id: object_id,
      source_type: object_type,
      destination_type: destination_model
    ).count
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

    def valid_relationship_hash(name, model, endpoint)
      model = model.to_s if model.kind_of?(Symbol)
      {
        :relationship_type => name,
        :related_model => model,
        :related_model_endpoint => endpoint
      }
    end

    def valid_relationships(object_type=nil)
      object_type ||= self.name

      valid_relationships = []
      DefaultRelationshipTypes.types.each do |name, rel|
        if rel[:source_type] == object_type && rel[:target_type] == object_type &&  rel[:symmetric]
          valid_relationships.push(
            valid_relationship_hash(name, rel[:source_type], :both))
        end
        if rel[:source_type] == object_type && !rel[:symmetric]
          valid_relationships.push(
            valid_relationship_hash(name, rel[:target_type], :destination))
        end
        if rel[:target_type] == object_type && !rel[:symmetric]
          valid_relationships.push(
            valid_relationship_hash(name, rel[:source_type], :source))
        end
      end
      valid_relationships
    end

    def has_valid_relationship?(type)
      valid_relationships.any? do |rel|
        rel[:relationship_type].to_s == type.to_s
      end
    end

    def related_models(object_type=nil)
      valid_relationships(object_type).reduce(Set.new) do |models, vr|
        models.add(vr[:related_model])
      end
    end

    def all_related_edges
      # Get all of the related edges for this model

      # Returns a list of all relationship edges going to/from this node.
      # An edge consists of {:source, :destination, :type}

      source_rels = Relationship.includes(:source, :destination).where(:source_type => self.to_s)
      dest_rels = Relationship.includes(:source, :destination).where(:destination_type => self.to_s)
      op_rels = ObjectPerson.includes(:person, :personable).where(:personable_type => self.to_s)

      edges = Set.new

      source_rels.each do |rel|
        edge = Edge.new(rel.source, rel.destination,rel.relationship_type_id)
        edges.add(edge)
      end
      dest_rels.each do |rel|
        edge = Edge.new(rel.source, rel.destination,rel.relationship_type_id)
        edges.add(edge)
      end
      op_rels.each do |op|
        edge = Edge.new(op.person, op.personable, "person_#{op.role}_for_#{self.to_s.underscore}")
        edges.add(edge)
      end

      # In addition to the standard relationships, include all of the
      # non-standard edges that are baked into the models.
      if self.methods.include? :custom_all_edges
        edges.merge(self.custom_all_edges)
      end

      edges
    end
  end
end
