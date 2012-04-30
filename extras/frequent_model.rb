module FrequentModel
  FREQUENCIES = [:day, :week, :month, :quarter, :year]

  def frequency_type
    FREQUENCIES[read_attribute(:frequency_type)]
  end

  def frequency_type=(value)
    write_attribute(:frequency_type, FREQUENCIES.index(value))
  end
end
