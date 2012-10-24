class RelationshipsController < ApplicationController

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

  def list_edit
    @form_params = {}
    @form_params[:relationship_type] = params[:relationship_type] if params[:relationship_type].present?
    @form_params[:object_type] = params[:object_type] if params[:object_type].present?
    @form_params[:object_id] = params[:object_id] if params[:object_id].present?
    @form_params[:related_side] = params[:related_side] if params[:related_side]
    @form_params[:related_model] = params[:related_model] if params[:related_model].present?
    @relationship_type = params[:relationship_type] if params[:relationship_type].present?
    @model = params[:object_type].constantize
    @object = @model.find(params[:object_id])

    @context = {
      :object_type => params[:object_type],
      :object_id => params[:object_id],
      :related_type => params[:related_model],
      :related_side => params[:related_side],
      :relationship_type => params[:relationship_type],
      :title => "Add Relationship",
      :source_title => "Select Object",
      :source_new_title => "New object",
      :source_search_text => "Search GRC",
      :target_title => "Current related objects",
      :option_new_url => url_for(:action => :new, :controller => params[:related_model].underscore.pluralize),
      :options_url => url_for(:action => :index, :controller => params[:related_model].underscore.pluralize),
      :selected_url => flow_relationships_path(
        @form_params
      )
    }

    respond_to do |format|
      format.html { render :layout => nil }
    end
  end

  def create
    if params[:items].present?
      errors, objects = {}, {}
      params[:items].keys.each do |id|
        item_errors, item_object = create_relationship(params[:items][id])
        errors[id] = item_errors if item_errors
        objects[id] = item_object
      end
    else
      item_errors, item_object = create_relationship(params[:relationship])
      errors = item_errors
      objects = [item_object]
    end

    puts '****'
    puts errors
    puts objects
    if errors.empty?
      render :json => objects.values.compact, :status => 200
    else
      render :json => { :errors => errors, :objects => objects }, status => 400
    end
  end

  def create_relationship(params)
    if params[:id].present? && params[:_destroy] == 'destroy'
      relationship = Relationship.find(params[:id])
      relationship.destroy
      [nil, nil]
    else
      if params[:id].present?
        relationship = Relationship.find(params[:id])
      else
        relationship = Relationship.new
      end

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

        if relationship.save
          [nil, relationship]
        else
          [relationship.error_messages, relationship]
        end
      end
    end
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
                  :related_side => 'source',
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
                  :related_side => 'both',
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

  def graph
    obj_type = params[:otype]
    obj_id = params[:oid]

    obj = obj_type.constantize.find(obj_id)
    graph_data = obj.traverse_related

    respond_to do |format|
      format.json { render :json => graph_data }
    end
  end

  private

    def load_product
      @product = Product.find(params[:id])
    end

    def relationship_params
      relationship_params = params[:product] || {}
      %w(type).each do |field|
        parse_option_param(relationship_params, field)
      end
      %w(start_date stop_date).each do |field|
        parse_date_param(relationship_params, field)
      end
      relationship_params
    end

end
