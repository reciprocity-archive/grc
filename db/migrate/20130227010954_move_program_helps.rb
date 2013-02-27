class MoveProgramHelps < ActiveRecord::Migration
  HELP_SLUG_CHANGES = {
    :program_cycles => :directive_cycles,
    :program_info => :directive_info,
    :programs_list => :directives_list,
    :program_controls => :directive_controls,
    :program_more_info => :directive_more_info,
    :program => :directive
  }

  def up
    transaction do
      HELP_SLUG_CHANGES.each do |old_slug, new_slug|
        help = Help.where(:slug => old_slug).first
        help.update_attribute(:slug, new_slug) if help.present?
      end
    end
  end

  def down
  end
end
