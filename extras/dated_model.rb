module DatedModel
  include ActiveSupport::Concern
  
  def self.included(model)
    model.validate :stop_date_later_than_start_date
  end
  
  def stop_date_later_than_start_date
    if self.has_attribute? :stop_date
      errors.add(:stop_date, 'Must be later than start date') unless
       self.start_date < self.stop_date
    elsif self.has_attribute? :end_at
      errors.add(:end_at, 'Must be later than start date') unless
        self.start_at < self.end_at
    end
  end
end