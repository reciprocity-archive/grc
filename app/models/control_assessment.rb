class ControlAssessment < ActiveRecord::Base
  include AuthoredModel
  include AuthorizedModel
  include SanitizableAttributes

  has_many :requests, :dependent => :nullify

  belongs_to :pbc_list
  belongs_to :control

  attr_accessible :control_version, :external_tod, :external_toe, :internal_tod, :internal_toe, :notes, :pbc_list, :control

  is_versioned_ext

  sanitize_attributes :notes

  validates_presence_of :pbc_list, :control

  def display_name
    control.display_name
  end

  def rotate_value!(field)
    next_value = case self.send(field)
      when nil then false
      when false then true
      else nil
    end
    update_attributes(field => next_value)
  end
end
