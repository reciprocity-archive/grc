# Sanitize attributes before validation.
#
# Usage in model:
#
#   sanitize_attributes :description, :documentation_description
#
module SanitizableAttributes
  # based on defaults from ActionView::Base.sanitized_allowed_tags with table tags added
  SANITIZED_ALLOWED_TAGS = %w(strong em b i p code pre tt samp kbd var sub sup dfn cite big small
    address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dl dt dd abbr acronym a img blockquote del ins
    table tr td th)

  # based on defaults from ActionView::Base.sanitized_allowed_attributes
  SANITIZED_ALLOWED_ATTRIBUTES = %w(href src width height alt cite datetime title class name xml:lang abbr)

  def self.included(model)
    model.extend(ClassMethods)
  end

  def sanitize!
    self.class.sanitizable_attributes.each do |attr_name|
      sanitized_value = ActionController::Base.helpers.sanitize(self.send("#{attr_name}"),
        :tags => SANITIZED_ALLOWED_TAGS,
        :attributes => SANITIZED_ALLOWED_ATTRIBUTES
      )

      self.send("#{attr_name}=", sanitized_value)
    end
  end

  module ClassMethods
    def sanitize_attributes(*attr_names)
      cattr_accessor :sanitizable_attributes
      self.sanitizable_attributes ||= []
      self.sanitizable_attributes += attr_names.to_a

      attr_names.each do |attr_name|
        define_method "#{attr_name}_inline" do
          ActionController::Base.helpers.sanitize(self.send(attr_name), :tags => SANITIZED_ALLOWED_TAGS - %w(ul ol li div br hr table td tr th))
        end
        define_method "#{attr_name}_stripped_with_newlines" do
          value = self.send(attr_name)
          value = value.gsub(/(?:\s*<\/?(?:li|ul|ol)>\s*)+/, "\n")
          value = ActionController::Base.helpers.sanitize(
            value, :tags => %w(br), :whitespace_elements => %w(i b))
          value = value.gsub(/\A(?:&nbsp;|<br\/?>|\s)+|(?:&nbsp;|<br\/?>|\s)+\Z/, '')
          value = value.gsub(/(?:\s*<br>\s*)+/, "\n\n")
          value = value.gsub(/&nbsp;/, ' ')
          value
        end
      end

      before_validation :sanitize!
    end
  end
end
