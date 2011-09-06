# Helper methods defined here can be accessed in any controller or view in the application

module GdataHelper
  def gdocs_by_title(docs)
    by_title = {}
    docs.values.each do |doc|
      by_title[doc.full_title] = doc
    end
    by_title
  end

  def auth_gdocs()
    if params[:token]
      client = Gdoc::Client.new
      session[:gtoken] = client.set_token params[:token], true
      redirect_to "#{request.scheme}://#{request.host_with_port}#{request.path}"
      return false
    end
    return true
  end

  def get_gdocs(opts = {})
    get_gdata('gdocs', opts) do |client|
      client.get_docs(opts)
    end
  end

  def get_gfolders(opts = {})
    get_gdata('gfolders', opts) do |client|
      client.get_folders(opts)
    end
  end

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

  def get_gdata_client(opts = {})
    client = Gdoc::Client.new

    if params[:token]
      session[:gtoken] = client.set_token params[:token], true
      redirect_to "#{request.scheme}://#{request.host_with_port}#{request.path}"
      return nil
    elsif session[:gtoken].nil?
      if opts[:ajax]
        next_url = opts[:retry_url]
        auth_url = client.authsub(next_url)
        @redirect_url = auth_url
        #response.write(partial "base/ajax_redirect")
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
end
