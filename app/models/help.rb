class Help < ActiveRecord::Base
  include AuthoredModel
  include SearchableModel
  include AuthorizedModel
  include SanitizableAttributes

  is_versioned_ext

  sanitize_attributes :content

  attr_accessible :title, :content, :slug
end
