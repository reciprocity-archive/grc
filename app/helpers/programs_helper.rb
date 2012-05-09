module ProgramsHelper
  # Set up a program and relevant stats for display
  def program_stats(program)
    stats = {}
    stats[:sections_count] = Section.where(:program_id => program.id).count()
    stats[:sections_done_count] = Section.joins(:controls).where(:program_id => program.id).count(:distinct => true)
    stats[:sections_undone_count] = Section.where(:program_id => program.id).count() - stats[:sections_done_count]
    stats[:sections_na_count] = 0
    controls = Control.joins(:sections).where(Section.arel_table[:program_id].eq(program.id))
    stats[:controls_count] = controls.count(:distinct => true)
    stats[:controls_parented_count] = controls.where(Control.arel_table[:parent_id].not_eq(nil)).count(:distinct => true)
    stats
  end
end
