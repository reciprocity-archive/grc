class Categorization < ActiveRecord::Base
  include AuthoredModel

  belongs_to :category
  belongs_to :categorizable, :polymorphic => true
end
