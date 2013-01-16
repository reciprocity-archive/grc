class MovePbcListsColumnsToCycles < ActiveRecord::Migration
  def up
    change_table :cycles do |t|
      t.string :title
      t.string :audit_firm
      t.string :audit_lead
      t.text :description
      t.string :status
      t.text :notes
    end

    Cycle.reset_column_information

    Cycle.all.each do |cycle|
      if cycle.program.nil?
        cycle.destroy
        next
      end

      pbc_lists = PbcList.where(:audit_cycle_id => cycle.id).all
      pbc_list = pbc_lists.last

      if pbc_list.nil?
        pbc_list = PbcList.new
        pbc_list.title = "Audit for #{cycle.program && cycle.program.title}"
        pbc_list.audit_cycle = cycle
        pbc_list.save!
      end

      cycle.title = pbc_list.title
      cycle.description = pbc_list.description
      cycle.notes = pbc_list.notes
      cycle.audit_firm = pbc_list.audit_firm
      cycle.audit_lead = pbc_list.audit_lead

      cycle.save!
    end
  end

  def down
    change_table :cycles do |t|
      t.remove :title
      t.remove :audit_firm
      t.remove :audit_lead
      t.remove :description
      t.remove :status
      t.remove :notes
    end
  end
end
