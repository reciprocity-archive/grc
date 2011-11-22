# Helper methods defined here can be accessed in any controller or view in the application

module DocumentHelper
  # Transform a document URL for display purposes.
  #
  # Currently just transforms a Google Docs url to the editable document
  # version.
  def transform_document_url(url)
    gdoc_url = Gdoc.edit_url_from_id_url(url)
    return gdoc_url if gdoc_url
    return url
  end
end
