module StateModel
  def state
    index = read_attribute(:state) || self.class.columns_hash['state'].default
    ControlState::VALUES[index]
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

