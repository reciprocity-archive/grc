require 'gdata'

module Gdoc
  DOCLIST_SCOPE = 'https://docs.google.com/feeds/'
  DOCLIST_DOWNLOD_SCOPE = 'https://docs.googleusercontent.com/'
  CONTACTS_SCOPE = 'https://www.google.com/m8/feeds/'
  SPREADSHEETS_SCOPE = 'https://spreadsheets.google.com/feeds/'

  DEFAULT_FEED = DOCLIST_SCOPE + 'default/private/full'

  DOCUMENT_DOC_TYPE = 'document'
  FOLDER_DOC_TYPE = 'folder'
  PRESO_DOC_TYPE = 'presentation'
  PDF_DOC_TYPE = 'pdf'
  SPREADSHEET_DOC_TYPE = 'spreadsheet'
  MINE_LABEL = 'mine'
  STARRED_LABEL = 'starred'
  TRASHED_LABEL = 'trashed'

  PARENT_RELATION = 'http://schemas.google.com/docs/2007#parent'
  SELF_RELATION = 'self'

  ATOM_NS = "http://www.w3.org/2005/Atom"

  KIND_SCHEME = "http://schemas.google.com/g/2005#kind"
  FOLDER_TERM = "http://schemas.google.com/docs/2007#folder"
  PARENT_REL = "http://schemas.google.com/docs/2007#parent" 

  ATOM_TYPE = "application/atom+xml"

  EDIT_URLS = {
    'document' => 'https://docs.google.com/a/google.com/document/d/%s/edit',
    'pdf' => 'https://docs.google.com/a/google.com/leaf?id=%s',
  }


  # Create a URI for internal identification of a google document
  def self.make_id_url(doc)
    return "xgdoc:#{doc.type}/#{doc.doc_id}"
  end

  # Convert an internal URI to a Google Docs URL for editing the document
  def self.edit_url_from_id_url(id_url)
    return nil if id_url.scheme != 'xgdoc'
    (type, doc_id) = id_url.path.split("/")
    edit_url = EDIT_URLS[type]
    return nil if edit_url.nil?
    return sprintf(edit_url, doc_id)
  end

  # Construct a Gdoc::Document from an API results entry
  def self.create_doc(entry)
    resource_id = entry.elements['gd:resourceId'].text.split(':')
    doc = Gdoc::Document.new(entry.elements['title'].text,
                             :type => resource_id[0],
                             :xml => entry.to_s)

    doc.doc_id = resource_id[1]
    doc.last_updated = DateTime.parse(entry.elements['updated'].text)
    if !entry.elements['gd:lastViewed'].nil?
      doc.last_viewed = DateTime.parse(entry.elements['gd:lastViewed'].text)
    end
    if !entry.elements['gd:lastModifiedBy/email'].nil?
      doc.last_modified_by = entry.elements['gd:lastModifiedBy/email'].text
    end
    doc.writers_can_invite = entry.elements['docs:writersCanInvite'].attributes['value']
    doc.author = entry.elements['author/email'].text

    entry.elements.each('link') do |link|
      doc.links[link.attributes['rel']] = link.attributes['href']
      if link.attributes['rel'] == SELF_RELATION
        doc.href = link.attributes['href']
      end
      if link.attributes['rel'] == PARENT_RELATION
        doc.parent = link.attributes['href']
      end
    end
    doc.links['acl_feedlink'] = entry.elements['gd:feedLink'].attributes['href']
    doc.links['content_src'] = entry.elements['content'].attributes['src']

    case doc.type
    when DOCUMENT_DOC_TYPE, PRESO_DOC_TYPE
      doc.links['export'] = DOCLIST_SCOPE +
        "download/documents/Export?docID=#{doc.doc_id}"
    when SPREADSHEET_DOC_TYPE
      doc.links['export'] = SPREADSHEETS_SCOPE +
        "download/spreadsheets/Export?key=#{doc.doc_id}"
    when PDF_DOC_TYPE
      doc.links['export'] = doc.links['content_src']
    end

    entry.elements.each('gd:feedLink/feed/entry') do |feedlink_entry|
      email = feedlink_entry.elements['gAcl:scope'].attributes['value']
      role = feedlink_entry.elements['gAcl:role'].attributes['value']
      doc.add_permission(email, role)
    end
    return doc
  end

  # A Google Docs API client
  class Client
    attr_reader :gclient

    def initialize()
      @gclient = GData::Client::DocList.new
      @gclient.version = '3.0'
      @gclient.source = 'CMS'
    end

    # Save a session auth token received through an incoming redirect
    # of the user's browser.
    def set_token(token, upgrade = false)
      @gclient.authsub_token = token
      return @gclient.auth_handler.upgrade if upgrade
      return token
    end

    def authsub(url)
      sess = true
      secure = false
      return @gclient.authsub_url(url, secure, sess, '')
    end

    def download(doc, type)
      url = doc.links['content_src'] + "&format=#{type}&exportFormat=#{type}"
      @gclient.get(url).body
    end

    # Get Google Docs given search options.
    #
    # opts[:folder] - optional Gdoc::Document representing a folder to search in
    #
    # Returns a map of doc IDs to Gdoc::Document
    def get_docs(opts = {})
      url = Gdoc::DEFAULT_FEED
      if opts[:folder]
        url = opts[:folder].links['content_src']
      end
      feed = @gclient.get(url)

      docs = {}
      feed.to_xml.elements.each('entry') do |entry|
        doc = Gdoc.create_doc(entry)
        docs[doc.href] = doc
      end
      docs
    end
 
    # Get Google Docs folders given search options.
    #
    # opts[:folder] - optional Gdoc::Document representing a folder to search in
    #
    # Returns a map of doc IDs to Gdoc::Document
    def get_folders(opts = {})
      url = Gdoc::DEFAULT_FEED
      folder = opts[:folder] || 'folder'
      url += "/-/#{folder}?showfolders=true"
      feed = @gclient.get(url)

      docs = {}
      feed.to_xml.elements.each('entry') do |entry|
        doc = Gdoc.create_doc(entry)
        docs[doc.href] = doc
      end

      docs.values.each do |doc|
        if doc.parent
          doc.parent = docs[doc.parent]
        end
      end
      docs
    end

    # Copy
    def copy(doc, new_title)
      url = doc.links['self']
      xm = Builder::XmlMarkup.new(:indent => 2)
      xm.instruct!
      body = xm.entry "xmlns" => ATOM_NS do
        xm.id url
        xm.title new_title
      end
      res = @gclient.post DEFAULT_FEED, body
      return Gdoc.create_doc(res.to_xml)
    end

    # Move a doc or folder into a folder
    def move_into_folder(doc, dest, opts = {})
      url = doc.type == 'folder' ? doc.links['content_src'] : doc.links['self']
      xm = Builder::XmlMarkup.new(:indent => 2)
      xm.instruct!
      body = xm.entry "xmlns" => ATOM_NS do
        xm.id url
      end
      res = @gclient.post dest.links['content_src'], body
      doc.parent = dest if doc.type == 'folder'
    end

    # Remove a doc or folder from a folder
    def remove_from_folder(doc, dest, opts = {})
      url = dest.links['content_src'] + "/#{doc.type}%3A#{doc.doc_id}"
      begin
        @gclient.headers['if-match'] = '*'
        res = @gclient.delete url
      ensure
        @gclient.headers['if-match'] = ''
      end
    end

    # Create a folder
    #
    # opts[:parent] optional parent folder
    def create_folder(title, opts = {})
      xm = Builder::XmlMarkup.new(:indent => 2)
      xm.instruct!
      body = xm.entry "xmlns" => ATOM_NS do
        xm.category :scheme => KIND_SCHEME, :term => FOLDER_TERM
        xm.title title
      end
      if opts[:parent]
        res = @gclient.post opts[:parent].links['content_src'], body
      else
        res = @gclient.post Gdoc::DEFAULT_FEED, body
      end
      doc = Gdoc.create_doc(res.to_xml)
      doc.parent = opts[:parent]
      doc
    end
 
    def upload(title, path) 
      begin
        resumable = get_resumable
        content_length = File.size(path)
        @gclient.headers['X-Upload-Content-Type'] = 'application/pdf'
        @gclient.headers['X-Upload-Content-Length'] = content_length
        xm = Builder::XmlMarkup.new(:indent => 2)
        xm.instruct!
        body = xm.entry "xmlns" => Gdoc::ATOM_NS do
          xm.title title
        end
        res = @gclient.post(resumable + '?convert=false', body)
        location = res.headers['location']
        @gclient.headers.delete('X-Upload-Content-Type')
        @gclient.headers.delete('X-Upload-Content-Length')
        @gclient.headers['Content-Type'] = 'application/pdf'
        File.open(path) do |f|
          pos = 0
          while !f.eof?
            chunk = f.read(512*1024)
            @gclient.headers['Content-Length']= "#{chunk.size}"
            @gclient.headers['Content-Range']= "bytes #{pos}-#{pos + chunk.size - 1}/#{content_length}"
            res = @gclient.put(location, chunk)
            location = res.headers['location']
            pos = pos + chunk.size
          end
        end
        return Gdoc.create_doc(res.to_xml)
      ensure
        @gclient.headers.delete('Content-Range')
        @gclient.headers.delete('Content-Type')
      end
    end

    def get_resumable
      xml = @gclient.get(Gdoc::DEFAULT_FEED).to_xml
      xml.elements.each('link') do |link|
        return link.attributes['href'] if link.attributes['rel'] == 'http://schemas.google.com/g/2005#resumable-create-media'
      end
      raise 'could not find resumable link in default feed'
    end
  end
end
