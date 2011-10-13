class DocumentController < ApplicationController
  include GdataHelper
  include DocumentHelper

  access_control :acl do
    allow :admin, :analyst
  end

  def index
    return unless auth_gdocs
    render 'document/index'
  end

  def sync
    folders = get_gfolders(:refresh => true) or return

    by_title = gdocs_by_title(folders)

    top = by_title['CMS']
    unless top
      flash[:error] = 'No CMS folder in your Google Docs'
      return render 'document/sync'
    end

    client = Gdoc::Client.new
    client.set_token session[:gtoken]

    @messages = []

    ['Systems', 'Accepted'].each do |name|
      unless by_title["#{top.full_title}/#{name}"]
        folder = client.create_folder(name, :parent => top)
        by_title["#{top.full_title}/#{name}"] = folder
        session[:gfolders] = {} # clear cache
        @messages << "Created #{folder.full_title}"
      end
    end

    systems = by_title["#{top.full_title}/Systems"]

    System.all.each do |sys|
      path = "#{systems.full_title}/#{sys.slug}"
      unless by_title[path]
        folder = client.create_folder(sys.slug, :parent => systems)
        session[:gfolders] = {} # clear cache
        @messages << "Created #{folder.full_title}"
      end
    end
    render 'document/sync'
  end
end
