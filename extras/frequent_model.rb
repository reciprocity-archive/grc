module FrequentModel
  FREQUENCIES = [:day, :week, :month, :quarter, :year]

  def frequency_type
    index = read_attribute(:frequency_type) ||
      self.class.columns_hash['frequency_type'].default
    FREQUENCIES[index]
  end

  def frequency_type=(value)
    write_attribute(:frequency_type, FREQUENCIES.index(value))
  end
end
