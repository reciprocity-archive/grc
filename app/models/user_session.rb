# A user session
class UserSession < Authlogic::Session::Base
  extend ActiveModel::Naming
  authenticate_with Account
  cookie_key "_cms_cred"
end
