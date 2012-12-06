class RelationshipsController < BaseMappingsController

  access_control :acl do
    allow :superuser
    allow :read, :read_relationship, :to => [:related_objects]
  end

  def index
    if params[:related_side].present? && params[:related_side] != 'both'
      related_side = params[:related_side]
      object_side = related_side == 'source' ? 'destination' : 'source'
      params["#{object_side}_id"] = params.delete(:object_id)
      params["#{object_side}_type"] = params.delete(:object_type)
      params["#{related_side}_type"] = params.delete(:related_model)
    else
      if params[:related_model].present? && params[:other_type].nil?
        params[:other_type] = params[:related_model]
      end
    end

    @objects = Relationship.index_query(params)

    if params[:related_side] == 'source'
      relationships_with_object = @objects.includes(:source).map do |o|
        obj = o.as_json
        obj["relationship"]["object"] = o.source.as_json(:root => false)
        obj
      end
    elsif params[:related_side] == 'destination'
      relationships_with_object = @objects.includes(:destination).map do |o|
        obj = o.as_json
        obj["relationship"]["object"] = o.destination.as_json(:root => false)
        obj
      end
    elsif params[:related_side] == 'both'
      relationships_with_object = @objects.includes(:destination, :source).map do |o|
        obj = o.as_json
        if o.source_type == params[:object_type] &&
            o.source_id == params[:object_id]
          related = o.source.as_json(:root => false)
        else
          related = o.destination.as_json(:root => false)
        end
        obj["relationship"]["object"] = related
        obj
      end
    end

    render :json => relationships_with_object
  end

  def related_objects
    obj_type = params[:otype]
    obj_id = params[:oid]
    obj_end = params[:obj_end]
    related_model = params[:related_model]
    obj = obj_type.constantize.find(obj_id)

    # Generate a list of all objects of that model which are related
    # to the source object

    related_is_source = Relationship.includes(:source).where(
      :destination_type => obj_type,
      :destination_id => obj_id,
      :source_type => related_model)
    related_is_dest = Relationship.includes(:destination).where(
      :source_type => obj_type,
      :source_id => obj_id,
      :destination_type => related_model)

    # Iterate through all valid relationship types
    # If it's not using the related model, skip it.
    # If we include forward, find and fill in forward relationships/forward objects
    # If we include backward, find and fill in backward relationships/backward objects
    @results = []
    obj.class.valid_relationships.each do |vr|
      if vr[:related_model].to_s == related_model
        result = {}

        relationship_type = RelationshipType.find_by_relationship_type(vr[:relationship_type])

        if (vr[:related_model_endpoint].to_s == "both") and
          (related_model == obj_type) and
          (relationship_type.forward_phrase == relationship_type.backward_phrase)
          # A symmetric relationship is where the related model is the same model
          # as the object, and the forwards and backwards descriptions are the same.
          # In that case, we combine both the source and destination results.
          if !relationship_type.nil?
            relationship_title = "#{related_model.to_s.pluralize.titleize} #{relationship_type.forward_phrase} this #{obj.class.to_s.titleize}"
          else
            relationship_title = "#{vr[:relationship_type]}:source"
          end

          edit_url = list_edit_flow_relationships_path(
                :object_id => obj.id,
                :object_type => obj.class.to_s,
                :relationship_type => vr[:relationship_type],
                :related_side => 'destination',
                :related_model => related_model)

          # First add the related_is_source set
          rels = related_is_source.select do |rel|
            rel.relationship_type == relationship_type
          end

          objects = Set.new
          rels.each do |rel|
            objects.add(rel.source)
          end

          # Also add the related_is_dest set.
          rels = related_is_dest.select do |rel|
            rel.relationship_type == relationship_type
          end

          rels.each do |rel|
            objects.add(rel.destination)
          end

          @results.push({
            :relationship_type_id => vr[:relationship_type],
            :relationship_title => relationship_title,
            :relationship_description => relationship_type ? relationship_type.description : "Unknown relationship type",
            :edit_url => edit_url,
            :objects => objects,
          })
        else
          if ["source", "both"].include? vr[:related_model_endpoint].to_s
            if !relationship_type.nil?
              relationship_title = "#{related_model.to_s.pluralize.titleize} #{relationship_type.forward_phrase} this #{obj.class.to_s.titleize}"
            else
              relationship_title = "#{vr[:relationship_type]}:source"
            end

            edit_url = list_edit_flow_relationships_path(
                  :object_id => obj.id,
                  :object_type => obj.class.to_s,
                  :relationship_type => vr[:relationship_type],
                  :related_side => vr[:related_model_endpoint],
                  :related_model => related_model)

            rels = related_is_source.select do |rel|
              rel.relationship_type == relationship_type
            end
            @results.push({
              :relationship_type_id => vr[:relationship_type],
              :relationship_title => relationship_title,
              :relationship_description => relationship_type ? relationship_type.description : "Unknown relationship type",
              :edit_url => edit_url,
              :objects => rels.map {|rel| rel.source},
            })
          end
          if ["destination", "both"].include? vr[:related_model_endpoint].to_s
            if !relationship_type.nil?
              relationship_title = "#{related_model.to_s.pluralize.titleize} #{relationship_type.backward_phrase} this #{obj.class.to_s.titleize}"
            else
              relationship_title = "#{vr[:relationship_type]}:dest"
            end

            edit_url = list_edit_flow_relationships_path(
                  :object_id => obj.id,
                  :object_type => obj.class.to_s,
                  :relationship_type => vr[:relationship_type],
                  :related_side => vr[:related_model_endpoint],
                  :related_model => related_model)

            rels = related_is_dest.select do |rel|
              rel.relationship_type == relationship_type
            end
            @results.push({
              :relationship_type_id => vr[:relationship_type],
              :relationship_title => relationship_title,
              :relationship_description => relationship_type ? relationship_type.description : "Unknown relationship type",
              :edit_url => edit_url,
              :objects => rels.map {|rel| rel.destination},
            })
          end
        end
      end
    end
  end

  def d3_format(objs, edges)
    nodes = []
    # Add node data, and create the lookup table of obj => node index
    obj_to_node_id = {}
    objs.each do |obj|
      # FIXME: This is because Person doesn't have a slug, and
      # display_name doesn't work here (it's often too long)
      if obj.class == Person
        name = obj.email
      else
        name = obj.slug
      end

      class_name = obj.class.to_s.underscore

      nodes.push({
        :type => class_name,
        :node => {
          :name => name
        },
        :link => Rails.application.routes.url_helpers.method("flow_#{class_name}_path").call(obj.id)
      })

      obj_to_node_id[obj] = nodes.length - 1
    end

    links = []
    edges.each do |edge|
      links.push({
          :source => obj_to_node_id[edge.source],
          :target => obj_to_node_id[edge.destination],
          :type => edge.type
        })
    end

    {
      :nodes => nodes,
      :links => links
    }
  end

  def graph
    obj_type = params[:otype]
    obj_id = params[:oid]
    abilities = params[:abilities]

    obj = obj_type.constantize.find(obj_id)

    if abilities && abilities != ''
      # Split abilities using |
      allowed_abilities = abilities.split('-').map {|a| a.to_sym}
      graph_data = obj.ability_graph(allowed_abilities)
    else
      graph_data = obj.ability_graph([:all])
    end

    respond_to do |format|
      format.json { render :json => d3_format(graph_data[:objs], graph_data[:edges]) }
    end
  end

  private

    def list_edit_context
      super.merge \
        :form_url => flow_relationships_path(list_form_params)
    end

    def list_form_context
      object = params[:object_type].constantize.find(params[:object_id])
      {
        :object => object,
        :context => {
          :object_type => params[:object_type],
          :object_id => params[:object_id],
          :related_type => params[:related_model],
          :related_side => params[:related_side],
          :relationship_type => params[:relationship_type],
          :title => "Link #{params[:related_model]} to this #{params[:object_type]}",
          :source_title => "Select #{params[:related_model]} to link",
          :source_search_text => "Search #{params[:related_model].pluralize}",
          :target_title => "#{params[:related_model].pluralize} linked to this #{params[:object_type]}",
          :option_new_url => url_for(:action => :new, :controller => params[:related_model].underscore.pluralize),
          :options_url => url_for(:action => :index, :controller => params[:related_model].underscore.pluralize),
          :selected_url => flow_relationships_path(list_form_params)
        }
      }
    end

    def list_form_params
      form_params = {}
      form_params[:relationship_type] = params[:relationship_type] if params[:relationship_type].present?
      form_params[:object_type] = params[:object_type] if params[:object_type].present?
      form_params[:object_id] = params[:object_id] if params[:object_id].present?
      form_params[:related_side] = params[:related_side] if params[:related_side]
      form_params[:related_model] = params[:related_model] if params[:related_model].present?
      form_params
    end

    def update_object(relationship, params)
      relationship.relationship_type = RelationshipType.where(
        :relationship_type => params[:relationship_type]).first

      if params[:related_side].present?
        related_type = params[:related_type].constantize
        related = related_type.find(params[:related_id])

        object_type = params[:object_type].constantize
        object = object_type.find(params[:object_id])

        if params[:related_side] == 'source'
          relationship.source = related
          relationship.destination = object
        else params[:related_side] == 'destination'
          relationship.destination = related
          relationship.source = object
        end
      end
    end
end
