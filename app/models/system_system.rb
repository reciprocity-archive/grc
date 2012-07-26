# A link between systems
class SystemSystem < ActiveRecord::Base
  belongs_to :parent,
    :foreign_key => 'parent_id', :class_name => 'System'

  belongs_to :child,
    :foreign_key => 'child_id', :class_name => 'System'
end
