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
