module SearchableModel
  def self.included(model)
    model.extend(ClassMethods)
  end

  def self.sphinx_servers
    @@sphinx_servers ||= begin
      servers = CMS_CONFIG['FULLTEXT']
      (servers or '').split(',').map do |host_port|
        { :host => host_port.split(':')[0],
          :port => host_port.split(':')[1].to_i }
      end
    end
    @@sphinx_servers
  end

  module ClassMethods
    def fulltext_search(q)
      # Check if Sphinx is enabled globally and for this model; if not, fallback to db_search
      if false && CMS_CONFIG["FULLTEXT"].present? && respond_to?(:search_for_ids)
        ids = search_for_ids(q).to_a
        where(:id => ids)
      else
        db_search(q)
      end
    end

    def db_search(q)
      t = arel_table
      q = "%#{q}%"
      where(t[:title].matches(q).or(t[:slug].matches(q)))
    end

    if CMS_CONFIG["FULLTEXT"].blank?
      def define_index
      end
    end
  end
end
