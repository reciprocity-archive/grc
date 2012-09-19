class FixCategoryScopes < ActiveRecord::Migration
  def up
    # Fix previously-created categories which don't specify a scope_id
    Category.where(:scope_id => nil).update_all(:scope_id => Control::CATEGORY_TYPE_ID)
  end

  def down
  end
end
