module ControlState
  VALUES = [ :green, :yellow, :red, :unknown ]
  STATE_WEIGHT = { :green => 10, :unknown => 15, :yellow  => 20, :red => 30 }
  STATE_IS_GOOD = { :green => true, :unknown => true }
end
