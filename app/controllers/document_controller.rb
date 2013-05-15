# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# Handle Google Docs integration

class DocumentController < ApplicationController
  include GdataHelper
  include DocumentHelper

#  access_control :acl do
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_document
#    end
#
#    actions :sync do
#      allow :update, :update_document
#    end
#  end

  before_filter :need_cycle

  # Show the list of Google docs
  def index
    return unless auth_gdocs
    @folders = get_gfolders()
    return if !@folders
    render 'document/index'
  end

  # Sync our local list of document folders with Google Docs.
  #
  # Ensure that folders exist for CMS/CYCLE, CMS/CYCLE/Systems, Cms/CYCLE/Accepted and each system.
  def sync
    folders = get_gfolders(:refresh => true)
    folders or return

    by_title = gdocs_by_title(folders)

    @messages = []

    top = by_title['CMS']
    unless top
      flash[:error] = 'No CMS folder in your Google Docs'
      return render 'document/sync'
    end

    client = get_gdata_client
    return unless client

    unless by_title[cycle_gfolder(@cycle)]
      folder = client.create_folder(@cycle.slug, :parent => top)
      by_title[cycle_gfolder(@cycle)] = folder
      session[:gfolders] = {} # clear cache
      @messages << "Created #{folder.full_title}"
    end

    cycle_folder = by_title["#{top.full_title}/#{@cycle.slug}"]

    ['Systems', 'Accepted'].each do |name|
      unless by_title["#{cycle_folder.full_title}/#{name}"]
        folder = client.create_folder(name, :parent => cycle_folder)
        by_title["#{cycle_folder.full_title}/#{name}"] = folder
        session[:gfolders] = {} # clear cache
        @messages << "Created #{folder.full_title}"
      end
    end

    systems = by_title["#{cycle_folder.full_title}/Systems"]

    System.all.each do |sys|
      path = system_gfolder(@cycle, sys)
      unless by_title[path]
        folder = client.create_folder(sys.slug, :parent => systems)
        session[:gfolders] = {} # clear cache
        @messages << "Created #{folder.full_title}"
      end
    end
  end
end
