class Relationship < ActiveRecord::Base
  include AuthoredModel

  # Note: No accessible attributes - you pretty much
  # never want to allow changes to these without authorization.

  belongs_to :source, :polymorphic => true
  belongs_to :destination, :polymorphic => true
  belongs_to :relationship_type

  is_versioned_ext

  scope :manages, where(:relationship_type_id => 'manager_of')


  def self.related_objects_for_delete(object)
    object_type = object.class.name
    object_id = object.id

    table = arel_table

    src_query = table[:source_type].eq(object_type).and(table[:source_id].eq(object.id))
    dst_query = table[:destination_type].eq(object_type).and(table[:destination_id].eq(object.id))

    objects = {}

    where(src_query).all.each do |rel|
      objects[rel.destination_type] ||= []
      objects[rel.destination_type] << rel.destination
    end

    where(dst_query).all.each do |rel|
      objects[rel.source_type] ||= []
      objects[rel.source_type] << rel.source
    end

    objects
  end

  def self.index_query(params, base_query=nil)
    if base_query.nil?
      base_query = self
    end
    objects = base_query

    if params[:relationship_type].present?
      objects = objects.where(:relationship_type_id => params[:relationship_type])
    end

    if params[:object_type].present?
      # Search for 'object' on either side of the relationship

      table = self.arel_table #Arel::Table.new(:relationships)
      forward_query = table[:source_type].eq(params[:object_type])
      reverse_query = table[:destination_type].eq(params[:object_type])

      if params[:object_id]
        # Search with object ID

        forward_query = forward_query.and(
          table[:source_id].eq(params[:object_id]))
        reverse_query = reverse_query.and(
          table[:destination_id].eq(params[:object_id]))
      end

      if params[:other_type].present?
        # Search for 'other' on whatever side 'object' is not on

        forward_query = forward_query.and(
          table[:destination_type].eq(params[:other_type]))
        reverse_query = reverse_query.and(
          table[:source_type].eq(params[:other_type]))

        if params[:other_id]
          # Search with object_type, other_type, object_id, other_id

          forward_query = forward_query.and(
            table[:destination_id].eq(params[:other_id]))
          reverse_query = reverse_query.and(
            table[:source_id].eq(params[:other_id]))
        end
      end

      objects = objects.where(forward_query.or(reverse_query))
    else
      if params[:source_type].present?
        objects = objects.where(:source_type => params[:source_type])

        if params[:source_id].present?
          objects = objects.where(:source_id => params[:source_id])
        end
      end

      if params[:destination_type].present?
        objects = objects.where(:destination_type => params[:destination_type])

        if params[:destination_id].present?
          objects = objects.where(:destination_id => params[:destination_id])
        end
      end
    end

    return objects
  end
end
