module SearchableModel
  def self.included(model)
    model.extend(ClassMethods)
  end

  module ClassMethods
    def search(q)
      q = "%#{q}%"
      t = arel_table
      where(t[:title].matches(q).or(t[:slug].matches(q)))
    end
  end
end
