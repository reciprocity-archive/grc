module DatedModel
  include ActiveSupport::Concern
  
  def self.included(model)
    model.validate :stop_date_later_than_start_date
  end
  
  def stop_date_later_than_start_date
    if self.has_attribute? :stop_date
      if self.start_date.present? && self.stop_date.present?
        errors.add(:stop_date, 'Must be later than start date') unless
          self.start_date <= self.stop_date
      end
    end
    if self.has_attribute? :end_at
      if self.start_at.present? && self.end_at.present?
        errors.add(:end_at, 'Must be later than start date') unless
          self.start_at <= self.end_at
      end
    end
    if self.has_attribute? :response_due_at
      if self.date_requested.present? && self.response_due_at.present?
        errors.add(:response_due_at, 'Must be later than date requested') unless
          self.date_requested <= self.response_due_at
      end
    end
  end
end
