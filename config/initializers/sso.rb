module CmsRails
  class Application < Rails::Application
    def self.sso_callback_url
      @@sso_callback rescue nil
    end

    def self.sso_callback_url=(url)
      @@sso_callback = url
    end
  end
end
