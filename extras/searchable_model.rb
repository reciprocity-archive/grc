module SearchableModel
  def self.included(model)
    model.extend(ClassMethods)
  end

  module ClassMethods
    def fulltext_search(q)
      if CMS_CONFIG["FULLTEXT"] == "1"
        ids = search_for_ids(q).to_a
        where(:id => ids)
      else
        t = arel_table
        q = "%#{q}%"
        where(t[:title].matches(q).or(t[:slug].matches(q)))
      end
    end
  end
end
