class ReorgControls < ActiveRecord::Migration
  class Program < ActiveRecord::Base
  end

  class Section < ActiveRecord::Base
    belongs_to :parent, :class_name => "Section"
  end

  def up
    raise "do not know how to migrate ControlControls" unless ControlControl.count == 0
    rename_table :control_control_objectives, :control_sections
    change_table :control_sections do |t|
      t.rename :control_objective_id, :section_id
    end

    remove_index :biz_process_control_objectives, :biz_process_id
    remove_index :biz_process_control_objectives, :control_objective_id
    rename_table :biz_process_control_objectives, :biz_process_sections
    change_table :biz_process_sections do |t|
      t.rename :control_objective_id, :section_id
      t.index :section_id
    end

    rename_table :system_control_objectives, :system_sections
    change_table :system_sections do |t|
      t.rename :control_objective_id, :section_id
    end

    change_table :controls do |t|
      t.integer :parent_id
      t.rename :regulation_id, :program_id
    end

    change_table :sections do |t|
      t.rename :regulation_id, :program_id
    end

    change_table :cycles do |t|
      t.rename :regulation_id, :program_id
    end

    Program.reset_column_information
    Section.reset_column_information

    Program.all.each do |oldr|
      Section.create(:slug => oldr.slug, :title => oldr.title, :description => oldr.description, :program_id => oldr)
    end

    ormap = {}
    Section.order(:slug).each do |s|
      ormap[s.slug] = s
    end

    Section.all(:order => :slug).each do |s|
      slug = s.slug
      slug = slug[0..-2]
      while slug != ""
        if ormap[slug]
          s.parent = ormap[slug]
          s.save or raise r.errors.inspect
          break
        end
        slug = slug[0..-2]
      end
      unless s.parent
        print "no parent for #{s.slug}\n"
      end
    end
  end

  def down
  end
end
