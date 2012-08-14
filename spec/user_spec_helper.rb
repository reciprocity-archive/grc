module UserSpecHelper
  # Set the rspec environment so that we can call stub_model
  def set_rspec(rspec)
    @_rspec = rspec
  end

  def current_user(stubs = {})
    return @current_user if @current_user

    role = (stubs.delete(:role) || :user).to_s

    if respond_to?(:stub_model)
      @current_user = stub_model(Account, stubs.merge(:role => role))
    else
      @current_user = @_rspec.stub_model(Account, stubs.merge(:role => role))
    end

    @current_user
  end

  def user_session(stubs = {}, user_stubs = {})
    user = current_user(user_stubs)
    @current_user_session ||= mock_model(UserSession, {:user => user, :record => user}.merge(stubs))
  end

  def login(session_stubs = {}, user_stubs = {})
    UserSession.stub!(:find).and_return(user_session(session_stubs, user_stubs))
  end

  def logout
    @current_user = nil
    @user_session = nil
  end
end
