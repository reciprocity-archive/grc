# A link between systems
class SystemSystem < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :parent, :child, :type, :order

  belongs_to :parent,
    :foreign_key => 'parent_id', :class_name => 'System'

  belongs_to :child,
    :foreign_key => 'child_id', :class_name => 'System'

  is_versioned_ext

  validate :does_not_link_to_self
  validate :does_not_create_cycles
  validate :does_not_duplicate_entry
  validate :both_entries_exist

  def does_not_link_to_self
    if parent_id == child_id
      errors.add(:base, "System cannot rely on itself.")
    end
  end

  def does_not_create_cycles
    if has_cycle_to_parent?
      errors.add(:base, "Cannot link to Systems that rely on this System.")
    end
  end

  def does_not_duplicate_entry
    systems = SystemSystem.where(:parent_id => self.parent_id, :child_id => self.child_id).all
    if systems.count > 1 || (systems.first && systems.first.id != self.id)
      errors.add(:base, "Cannot create duplicate links")
    end
  end
  
  def both_entries_exist
    errors.add(:base, "System does not exist") unless System.where(:id => [parent_id, child_id]).count == 2
  end

  def has_cycle_to_parent?
    next_ids = [child_id]
    while next_ids.size > 0
      next_ids = SystemSystem.
        where(:parent_id => next_ids.uniq).
        all.
        map(&:child_id) - next_ids
      if next_ids.include?(parent_id)
        return true
      end
    end
  end
end
