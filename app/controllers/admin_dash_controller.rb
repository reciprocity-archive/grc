# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Admin dashboard
class AdminDashController < ApplicationController

  access_control :acl do
    allow :admin, :superuser
  end

  layout 'dashboard'

  def index
    @accounts = Account.all
    @people = Person.all
  end
end

