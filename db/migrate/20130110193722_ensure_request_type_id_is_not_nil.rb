class EnsureRequestTypeIdIsNotNil < ActiveRecord::Migration
  def up
    Request.all.reject(&:type_name).each{ |r| r.update_attribute(:type_id, 1) }
  end

  def down
  end
end
