# Helper methods defined here can be accessed in any controller or view in the application

module GdataHelper
  # Transform a list of docs to a map by title
  def gdocs_by_title(docs)
    by_title = {}
    docs.values.each do |doc|
      by_title[doc.full_title] = doc
    end
    by_title
  end

  # Check if this is a redirect from Google Docs with an auth token.
  #
  # If so, memoize the token and redirect to real destination.
  #
  # Returns true if the current request is not from gdocs and the request
  # can continue normally.
  def auth_gdocs()
    if params[:token]
      client = Gdoc::Client.new
      session[:gtoken] = client.set_token(params[:token], true)
      redirect_to "#{request.scheme}://#{request.host_with_port}#{request.path}"
      return false
    end
    return true
  end

  # Get a list of gdocs from the api
  def get_gdocs(opts = {})
    get_gdata('gdocs', opts) do |client|
      client.get_docs(opts)
    end
  end

  # Get a list of gdocs folders from the api
  def get_gfolders(opts = {})
    get_gdata('gfolders', opts) do |client|
      client.get_folders(opts)
    end
  end

  # Generic method to get gdocs or gfolders.
  #
  # There is a cache, which can be bypassed with opts[:refresh] or params[:r]
  #
  # Returns nil if we had to issue a redirect to authenticate the user to gdocs.
  def get_gdata(key, opts = {})
    if params[:r] || opts[:refresh]
      session[key] = {}
    else
      session[key] ||= {}
    end

    if session[key][opts[:folder]]
      return session[key][opts[:folder]]
    end

    client = get_gdata_client(opts)

    return nil if client.nil?

    docs = yield(client)

    session[key][opts[:folder]] = docs
  end

  # Obtain an API client object.
  #
  # Returns nil if we had to issue a redirect to authenticate the user to gdocs.
  #
  # This works inside an AJAX request.
  def get_gdata_client(opts = {})
    client = new_client

    if params[:token]
      session[:gtoken] = client.set_token(params[:token], true)
      redirect_to "#{request.scheme}://#{request.host_with_port}#{request.path}"
      return nil
    elsif session[:gtoken].nil?
      if opts[:ajax]
        next_url = opts[:retry_url]
        auth_url = client.authsub(next_url)
        @redirect_url = auth_url
        render :partial => 'base/ajax_redirect'
      else
        next_url = "#{request.scheme}://#{request.host_with_port}#{request.path}"
        redirect_to client.authsub(next_url)
      end
      return nil
    end

    client.set_token session[:gtoken]

    client
  end

  def new_client
     Gdoc::Client.new
  end

  # Full path of the folder that contains
  def cycle_gfolder(cycle)
    "CMS/#{cycle.slug}"
  end

  def system_gfolder(cycle, system = nil)
    system ? "CMS/#{cycle.slug}/Systems/#{system.slug}" : "CMS/#{cycle.slug}/Systems"
  end

  def accepted_gfolder(cycle)
    "CMS/#{cycle.slug}/Accepted"
  end

  def new_evidence_gfolder(cycle)
    "CMS/#{cycle.slug}/New Evidence"
  end
end
