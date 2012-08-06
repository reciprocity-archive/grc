# Describes a type of Document.
#
# Mainly use to classify types of evidence so that they can be
# organized when attached to Controls
class DocumentDescriptor < ActiveRecord::Base
  include AuthoredModel

  attr_accessible :title, :description

  def display_name
    title
  end

  is_versioned_ext
end
