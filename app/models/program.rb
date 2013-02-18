# A Program which links Directives
#
# The top of the Program -> Directive -> Control hierarchy
class Program < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes

  attr_accessible :title, :slug, :description, :start_date, :stop_date, :url

  has_many :program_directives, :dependent => :destroy
  has_many :directives, :through => :program_directives

  is_versioned_ext

  sanitize_attributes :description

  validates :title,
    :presence => { :message => "needs a value" }

  def display_name
    slug
  end
end
