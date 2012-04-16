# System to Control many to many
#
# Some additional attributes are attached, including the state of the control
# and a ticket (if state is not green).  Since a control can apply to systems,
# these attributes cannot be attached to it directly.
class SystemControl < ActiveRecord::Base
  include AuthoredModel

  after_initialize do
    self.state = :green if self.state.nil?
  end

  validates :state, :presence => true

  # A set of documents used as evidence in an audit
  has_many :evidences, :class_name => 'Document', :through => :document_system_control
  has_many :document_system_control

  belongs_to :control
  belongs_to :system
  belongs_to :cycle

  is_versioned_ext

  def state
    ControlState::VALUES[read_attribute(:state)]
  end

  def state=(value)
    write_attribute(:state, ControlState::VALUES.index(value))
  end

  def <=>(other)
    return control.slug <=> other.control.slug;
  end

  def evidence_complete?
    evidences.all? { |ev| ev.complete? }
  end

  def good_state?
    ControlState::STATE_IS_GOOD[state]
  end

  def self.by_system_control(system_id, control_id, cycle)
    sc = SystemControl
      .where(:system_id => system_id,
             :control_id => control_id,
             :cycle_id => cycle)
      .first
  end

  # Used by the slug filter widget
  def self.slugfilter(prefix)
    if !prefix.blank?
      joins(:control).where("controls.slug LIKE ?", "#{prefix}%")
    else
      where({})
    end
  end

  # Whether this evidence is attached to any SystemControls
  def self.evidence_attached?(evidence)
    DocumentSystemControl.where(:evidence => evidence).any?
  end

end
