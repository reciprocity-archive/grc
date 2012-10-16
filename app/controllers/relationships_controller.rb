class RelationshipsController < ApplicationController

  access_control :acl do
    allow :superuser
    allow :read, :read_relationship, :to => [:related_objects]
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

          edit_url = url_for(:action => 'related',
                :controller => 'programs',
                :oid => obj.id,
                :otype => obj.class.to_s,
                :relationship_type => vr[:relationship_type],
                :related_side => 'source',
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
            :relationship_type_id => vr[:relationship_type_id],
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

            edit_url = url_for(:action => 'related',
                  :controller => 'programs',
                  :oid => obj.id,
                  :otype => obj.class.to_s,
                  :relationship_type => vr[:relationship_type],
                  :related_side => 'source',
                  :related_model => related_model)

            rels = related_is_source.select do |rel|
              rel.relationship_type == relationship_type
            end
            @results.push({
              :relationship_type_id => vr[:relationship_type_id],
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

            edit_url = url_for(:action => 'related',
                  :controller => 'programs',
                  :oid => obj.id,
                  :otype => obj.class.to_s,
                  :relationship_type => vr[:relationship_type],
                  :related_side => 'source',
                  :related_model => related_model)

            rels = related_is_dest.select do |rel|
              rel.relationship_type == relationship_type
            end

            @results.push({
              :relationship_type_id => vr[:relationship_type_id],
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

end
