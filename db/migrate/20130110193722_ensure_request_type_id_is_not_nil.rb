class EnsureRequestTypeIdIsNotNil < ActiveRecord::Migration
  def up
    Request.all.reject(&:type_name).each{ |r| r.type_id = 1; r.save! }
  end

  def down
  end
end
