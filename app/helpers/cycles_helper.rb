module CyclesHelper

  def generate_default_title_for_cycle(program=nil)
    default_title = (program.nil? ? "" : program.title + " ") + "Audit"
    count = Cycle.where(Cycle.arel_table[:title].matches("%#{default_title}%")).count
    default_title +=  count > 0 ? " " + (count + 1).to_s : ""
    return "#{Date.today.year} - " + default_title
  end
end