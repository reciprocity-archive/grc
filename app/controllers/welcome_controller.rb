class WelcomeController < ApplicationController
  skip_before_filter :require_user
end
