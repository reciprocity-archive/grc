class Categorization < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :category, :categorizable

  belongs_to :category
  belongs_to :categorizable, :polymorphic => true

  is_versioned_ext
end
