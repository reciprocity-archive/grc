class Categorization < ActiveRecord::Base
  belongs_to :category
  belongs_to :stuff, :polymorphic => true
end
