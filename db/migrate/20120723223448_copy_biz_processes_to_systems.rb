class CopyBizProcessesToSystems < ActiveRecord::Migration
  class BizProcess < ActiveRecord::Base
  end

  def up
    System.reset_column_information

    # Copy BizProcess and relations to System
    BizProcess.all.each do |bp|
      sys = System.create!(
        :title => bp.title,
        :slug => bp.slug,
        :description => bp.description,
        :owner_id => bp.owner_id,
        :modified_by_id => bp.modified_by_id,
        :created_at => bp.created_at,
        :updated_at => bp.updated_at,
        :infrastructure => false,
        :is_biz_process => true
      )

      # Map BizProcessControls to SystemControls
      bp.biz_process_controls.all.each do |bpc|
        SystemControl.create!(
          :system => sys,
          :control => bpc.control,
          :state => bpc.state,
          :ticket => bpc.ticket,
          :modified_by_id => bpc.modified_by_id,
          :created_at => bpc.created_at,
          :updated_at => bpc.updated_at
        )
      end

      # Map BizProcessSections to SystemSections
      bp.biz_process_sections.all.each do |bps|
        SystemSection.create!(
          :system => sys,
          :section => bps.section,
          :modified_by_id => bps.modified_by_id,
          :created_at => bps.created_at,
          :updated_at => bps.updated_at
        ) if bps.section
      end

      SystemSystem.reset_column_information

      # Map BizProcessSystems to SystemSystems
      bp.biz_process_systems.all.each do |bps|
        SystemSystem.create!(
          :parent => sys,
          :child => bps.system,
          :modified_by_id => bps.modified_by_id,
          :created_at => bps.created_at,
          :updated_at => bps.updated_at
        )
      end

      ObjectPerson.reset_column_information
      ObjectDocument.reset_column_information

      # Move ObjectDocuments and ObjectPeople instead of
      # BizProcessDocuments and BizProcessPeople, since
      # those were already mapped in previous migrations
      ObjectPerson.where(
        :personable_type => bp.class,
        :personable_id => bp.id
      ).all.each do |op|
        op.personable = sys
        op.save
      end

      ObjectDocument.where(
        :documentable_type => bp.class,
        :documentable_id => bp.id
      ).all.each do |op|
        op.documentable = sys
        op.save
      end
    end

    # Remove BizProcess tables
    #drop_table :biz_process_controls
    #drop_table :biz_process_documents
    #drop_table :biz_process_people
    #drop_table :biz_process_sections
    #drop_table :biz_process_systems
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
