module ImportHelper
  def trim_array(a)
    while !a.empty? && a.last.blank?
      a.pop
    end
    a
  end
end
