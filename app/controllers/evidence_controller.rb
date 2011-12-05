# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2011
# License:: Apache 2.0

# Handle evidence collection

class EvidenceController < ApplicationController
  include GdataHelper
  include DocumentHelper
  include ApplicationHelper

  access_control :acl do
    allow :admin, :analyst
  end

  # Show the tree of (possibly filtered) systems.
  #
  # We may get a POST here if a filter is changed.
  #
  # We may also receive a GET with a Google Docs oauth token, which will be handled
  # with auth_gdocs.
  def index
    if request.post?
      # TODO: memoize tree open/close state
      redirect_to :action => :index
    else
      return unless auth_gdocs
      @systems = filter_systems(System.all(:order => :slug))
    end
  end

  # Show an open Control - AJAX
  def show_closed_control
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render(:partial => "closed_control", :locals => {:sc => sc})
  end

  # Show a closed Control - AJAX
  def show_control
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render(:partial => "control", :locals => {:sc => sc})
  end

  # Show a document attachment form - AJAX
  def new
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    desc = DocumentDescriptor.get(params[:descriptor_id])
    @document = Document.new
    render(:partial => "attach_form", :locals => {:sc => sc, :desc => desc})
  end

  # Show a Google doc attachment form - AJAX
  def new_gdoc
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    desc = DocumentDescriptor.get(params[:descriptor_id])

    folders = get_gfolders(:ajax => true, :retry_url => url_for(:action => :index))
    return unless folders

    by_title = gdocs_by_title(folders)
    sys_folder = by_title["CMS/Systems/#{sc.system.slug}"]

    @docs = get_gdocs(:folder => sys_folder, :ajax => true, :retry_url => url_for(:action => :index))
    return unless @docs

    render(:partial => "attach_form_gdoc", :locals => {:sc => sc, :desc => desc})
  end

  # Attach a document (either Google doc or regular)
  def attach
    @system_control = SystemControl.by_system_control(params[:system_id], params[:control_id])
    desc = DocumentDescriptor.get(params[:descriptor_id])

    doc_params = params[:document]
    gdocs_param = doc_params[:gdocs]
    if gdocs_param
      gdocs_param = [ gdocs_param ] unless gdocs_param.is_a?(Array)
      folders = get_gfolders
      return unless folders

      by_title = gdocs_by_title(folders)
      sys_folder = by_title["CMS/Systems/#{@system_control.system.slug}"]
      accepted_folder = by_title["CMS/Accepted"]

      docs = get_gdocs(:folder => sys_folder)
      return if docs.nil?
      gdocs_param.each do |doc_href|
        gdoc = docs[doc_href]
        if gdoc.nil?
          flash[:error] = "Failed to attach some docs"
        else
          gclient = get_gdata_client
          copy = gclient.copy(gdoc, "Evidence - #{gdoc.title}")
          doc =  Document.first_or_create(
            { :link => Gdoc.make_id_url(copy) },
            { :title => gdoc.title, :document_descriptor => desc
          })

          if !SystemControl.evidence_attached?(doc)
            # newly attached - put it under the accepted folder
            gclient.move_into_folder(copy, accepted_folder)
            gclient.move_into_folder(copy, sys_folder)
          end

          #puts "---------------------------"
          #puts doc.inspect
          #puts (@system_control.evidences.map {|x| x.id}).inspect
          #puts @system_control.evidences.include?(doc)
          if @system_control.evidences.include?(doc)
            flash[:error] = "Document already attached"
          elsif doc.document_descriptor == desc
            @system_control.evidences << doc
          else
            flash[:error] = "Document already exists with another descriptor"
          end
        end
      end
    else
      doc = Document.first_or_create(
        { :link => doc_params[:link] },
        { :title => doc_params[:title], :document_descriptor => desc
      })
      if doc.document_descriptor == desc
        @system_control.evidences << doc
      else
        flash[:error] = "Document already exists with another descriptor"
      end
      @system_control.evidences << doc
    end
    # FIXME
    @system_control.evidences.save!
    flash[:notice] = "Attached evidence to #{@system_control.system.title} / #{@system_control.control.title}" if flash[:error].nil?
    redirect_to :action => :index
  end

  # Show a document - AJAX
  def show
    document = Document.get(params[:document_id])
    render(:partial => "document", :locals => {:document => document})
  end

  # Update a regular document - AJAX
  def update
    document_id = params[:document_id]
    document = Document.get(document_id)
    document.update!(params[:document])
    render(:partial => 'document', :locals => {:document => document})
  end

  # Destroy a document - AJAX
  def destroy
    system_control = SystemControl.by_system_control(params[:system_id], params[:control_id])
    doc = Document.get(params[:document_id])
    system_control.evidences.delete(doc)
    system_control.evidences.save
    if doc.link.scheme == 'xgdoc'
      folders = get_gfolders
      return unless folders

      by_title = gdocs_by_title(folders)
      sys_folder = by_title["CMS/Systems/#{system_control.system.slug}"]
      accepted_folder = by_title["CMS/Accepted"]
      docs = get_gdocs(:folder => sys_folder)
      (type, docid) = doc.link.path.split('/')
      gdoc = nil
      docs.each do |url, d|
        if url.end_with?(docid)
          gdoc = d
        end
      end
      gclient = get_gdata_client
      if !SystemControl.evidence_attached?(doc) && gdoc
        # not attached to any SystemControls  - remove it from the accepted folder
        gclient.remove_from_folder(gdoc, accepted_folder)
      end
    end
    flash[:notice] = "Detached evidence from #{system_control.system.title} / #{system_control.control.title}" if flash[:error].nil?
    redirect_to :action => :index
  end

  # User reviews a document by marking it pass/fail/maybe - AJAX
  def review
    document_id = params[:document_id]
    document = Document.get(document_id)
    document.reviewed = params[:value] != "maybe"
    document.good = params[:value] == "1"
    document.save!
    render(:partial => 'document', :locals => {:document => document})
  end
end
