class Response < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel

  attr_accessible :request, :system, :status

  belongs_to :request
  belongs_to :system

  is_versioned_ext

  validates :request, :system,
    :presence => { :message => "needs a value" }

  def display_name
    "#{request.pbc_control_code} - #{system.title}"
  end

  def as_json_with_system(options={})
    as_json(options.merge(:include => { :system => { :include => [:people, { :documents => { :methods => :link_url }} , :object_people, :object_documents] } }))
  end
end
