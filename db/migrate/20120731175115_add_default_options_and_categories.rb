class AddDefaultOptionsAndCategories < ActiveRecord::Migration
  def up
    Option.reset_column_information
    Category.reset_column_information
    Categorization.reset_column_information

    options = {
      :control_type => [],
      :control_kind => ["Reactive", "Directive", "Detective", "Preventative"],
      :control_means => ["Manual", "Manual with Segregation of Duties", "Automated"],
      :system_type => ["Infrastructure"]
    }

    options.each do |k, opts|
      opts.each do |opt|
        Option.create(:role => k.to_s, :title => opt)
      end
    end

    categories = [
      ["Access Control", ["Access Management", "Authorization", "Authentication"]],
      ["Change Management", ["Segregation of Duties", "Configuration Management"]],
      ["Business Continuity", ["Disaster Recovery", "Physical Security"]],
      ["Governance", ["Training", "Policies & Procedures", "Monitoring"]]
    ]

    categories.each do |k, opts|
      c = Category.ctype(Control::CATEGORY_TYPE_ID).create(:name => k)
      opts.each do |opt|
        d = Category.ctype(Control::CATEGORY_TYPE_ID).create(:name => opt)
        d.move_to_child_of(c)
      end
    end
  end

  def down
  end
end
