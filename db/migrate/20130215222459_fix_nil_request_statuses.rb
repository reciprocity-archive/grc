class FixNilRequestStatuses < ActiveRecord::Migration
  def up
    Request.where(:status => nil).all.each do |req|
      req.update_attribute(:status, 'Draft')
    end
  end

  def down
  end
end
