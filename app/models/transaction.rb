class Transaction < ActiveRecord::Base
  include AuthoredModel
  include SluggedModel

  belongs_to :system

  is_versioned_ext

end
