# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

# Admin dashboard
class AdminDashController < ApplicationController

  access_control :acl do
    allow :superuser
  end

  layout 'dashboard'

  def index
    @accounts = allowed_objs(Account.all, :read)
    @people = allowed_objs(Person.all, :read)
    @root_categories = allowed_objs(Category.roots, :read)
    @options = allowed_objs(Option.all, :read)
  end
end
