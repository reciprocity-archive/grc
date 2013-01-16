class MultiEmailValidator < ActiveModel::EachValidator
  EMAIL_RE = /([^@\s]+)(?:@((?:[-a-z0-9]+\.)+[a-z]{2,}))/i
  EMAILS_RE = /\A\s*#{EMAIL_RE}(?:\s*[, ]\s*#{EMAIL_RE})*\Z/i

  def validate_each(record, attribute, value)
    unless value =~ EMAILS_RE #/\A([^@\s]+)(?:@((?:[-a-z0-9]+\.)+[a-z]{2,}))?\z/i
      record.errors[attribute] << (options[:message] || "must be one or more emails")
    end
  end
end
