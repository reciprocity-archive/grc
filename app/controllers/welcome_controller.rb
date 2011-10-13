class WelcomeController < ApplicationController
  skip_before_filter :require_user

  access_control :acl do
    allow all
  end
end
