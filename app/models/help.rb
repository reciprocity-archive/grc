class Help < ActiveRecord::Base
  include AuthoredModel
  include SearchableModel
  include AuthorizedModel

  is_versioned_ext

  attr_accessible :content, :slug
end
