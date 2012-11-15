class UpdateLanguagesAndControlKinds < ActiveRecord::Migration
  def up
    o = Option.where(:role => 'control_kind', :title => 'Directive').first
    if o
      o.title = 'Administrative'
      o.save
    end

    o = Option.where(:role => 'control_means', :title => 'Manual with Segregation of Duties').first
    if o
      o.title = 'Manual w Segregation of Duties'
      o.save
    end

    Option.where(:role => 'language', :title => 'English').first_or_create!
  end

  def down
  end
end
