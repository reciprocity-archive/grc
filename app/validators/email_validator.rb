class EmailValidator < ActiveModel::EachValidator
  EMAIL_RE = /([^@\s]+)(?:@((?:[-a-z0-9]+\.)+[a-z]{2,}))/i
  EMAILS_RE = /\A\s*#{EMAIL_RE}(?:\s*[, ]\s*#{EMAIL_RE})*\Z/i

  def validate_each(record, attribute, value)
    unless value =~ /^#{EMAIL_RE}$/
      record.errors[attribute] << (options[:message] || "must be an email")
    end
  end
end
