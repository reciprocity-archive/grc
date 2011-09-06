class EvidenceController < ApplicationController
  include GdataHelper
  include DocumentHelper
  include ApplicationHelper

  def index
    if request.post?
      redirect_to :action => :index
    else
      return unless auth_gdocs
      @systems = filter_systems(System.all)
    end
  end

  def show_closed_control
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render(:partial => "evidence/closed_control", :locals => {:sc => sc})
  end

  def show_control
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    render(:partial => "evidence/control", :locals => {:sc => sc})
  end

  def new
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    desc = DocumentDescriptor.get(params[:descriptor_id])
    @document = Document.new
    render(:partial => "evidence/attach_form", :locals => {:sc => sc, :desc => desc})
  end

  def new_gdoc
    sc = SystemControl.by_system_control(params[:system_id], params[:control_id])
    desc = DocumentDescriptor.get(params[:descriptor_id])

    folders = get_gfolders(:ajax => true, :retry_url => url_for(:action => :index))
    return unless folders

    by_title = gdocs_by_title(folders)
    sys_folder = by_title["CMS/Systems/#{sc.system.slug}"]

    @docs = get_gdocs(:folder => sys_folder, :ajax => true, :retry_url => url_for(:action => :index))
    return unless @docs

    render(:partial => "evidence/attach_form_gdoc", :locals => {:sc => sc, :desc => desc})
  end

  def attach
    @system_control = SystemControl.by_system_control(params[:system_id], params[:control_id])
    desc = DocumentDescriptor.get(params[:descriptor_id])

    folders = get_gfolders
    return unless folders

    by_title = gdocs_by_title(folders)
    sys_folder = by_title["CMS/Systems/#{@system_control.system.slug}"]
    accepted_folder = by_title["CMS/Accepted"]

    doc_params = params[:document]
    if doc_params[:gdocs]
      docs = get_gdocs(:folder => sys_folder)
      return if docs.nil?
      doc_params[:gdocs].each do |doc_href|
        gdoc = docs[doc_href]
        if gdoc.nil?
          flash[:error] = "Failed to attach some docs"
        else
          doc =  Document.first_or_create(
            { :link => Gdoc.make_id_url(gdoc) },
            { :title => gdoc.title, :document_descriptor => desc
          })

          gclient = get_gdata_client
          if !SystemControl.evidence_attached?(doc)
            # newly attached - put it under the accepted folder
            gclient.move_into_folder(gdoc, accepted_folder)
          end

          puts "---------------------------"
          puts doc.inspect
          puts (@system_control.evidences.map {|x| x.id}).inspect
          puts @system_control.evidences.include?(doc)
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
      puts "XXXXXXXXXXXXXXXXXXXXXXXXX"
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
    puts @system_control.evidences.dirty?
    # FIXME
    @system_control.evidences.save!
    flash[:notice] = "Attached evidence to #{@system_control.system.title} / #{@system_control.control.title}" if flash[:error].nil?
    redirect_to :action => :index
  end

  def show
    document = Document.get(params[:document_id])
    render(:partial => "evidence/document", :locals => {:document => document})
  end

  def update
    document_id = params[:document_id]
    document = Document.get(document_id)
    document.update!(params[:document])
    render(:partial => 'evidence/document', :locals => {:document => document})
  end

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

  def review
    document_id = params[:document_id]
    document = Document.get(document_id)
    document.reviewed = params[:value] != "maybe"
    document.good = params[:value] == "1"
    document.save!
    render(:partial => 'evidence/document', :locals => {:document => document})
  end
end
