# System to Control many to many
#
# Some additional attributes are attached, including the state of the control
# and a ticket (if state is not green).  Since a control can apply to systems,
# these attributes cannot be attached to it directly.
class SystemControl
  include DataMapper::Resource

  property :id, Serial
  property :state, Enum[*ControlState::VALUES], :default => :green, :required => true
  property :ticket, String

  # A set of documents used as evidence in an audit
  has n, :evidences, 'Document', :through => Resource

  belongs_to :control
  belongs_to :system

  # why/what/how free text
  property :test_why, Text
  property :test_impact, Text
  property :test_recommendation, Text

  property :created_at, DateTime
  property :updated_at, DateTime

  def <=>(other)
    return control.slug <=> other.control.slug;
  end

  def evidence_complete?
    evidences.all? { |ev| ev.complete? }
  end

  def good_state?
    ControlState::STATE_IS_GOOD[state]
  end

  def self.by_system_control(system_id, control_id)
    sc = SystemControl.first(:system_id => system_id,
                             :control_id => control_id)
  end

  # Used by the slug filter widget
  def self.slugfilter(prefix)
    if !prefix.blank?
      all(:control => {:slug.like => "#{prefix}%"})
    else
      all()
    end
  end

  # Whether this evidence is attached to any SystemControls
  def self.evidence_attached?(evidence)
    DocumentSystemControl.all(:evidence => evidence).any?
  end

end
