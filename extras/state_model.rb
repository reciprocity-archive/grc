module StateModel
  DEFAULT_STATE = 0

  def state
    ControlState::VALUES[read_attribute(:state) || DEFAULT_STATE]
  end

  def state=(value)
    write_attribute(:state, ControlState::VALUES.index(value))
  end

  def good_state?
    ControlState::STATE_IS_GOOD[state]
  end

  def self.included(model)
    model.validates :state, :presence => true
  end
end

