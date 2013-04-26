class DeleteReferencesWithoutUrLs < ActiveRecord::Migration
  def up
    Document.where(:link => nil).concat(Document.where(:link => "")).each {|x| x.destroy}
  end

  def down
  end
end
