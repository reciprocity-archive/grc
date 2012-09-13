# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#

SIZE=20

ACCOUNTS = {
  :root => :superuser,
  :user => :user,
  :owner1 => :user,
  :owner2 => :user
}

ActiveRecord::Base.transaction do

  # Accounts
  ACCOUNTS.each do |name, role|
    Account.
      where(:email => "#{name}@t.com").
      first_or_create!(
        {:password => name, :password_confirmation => name, :role => role},
        :without_protection => true)
  end

  account_person1 = Account.find_by_email('owner1@t.com').person
  account_person2 = Account.find_by_email('owner2@t.com').person

  # Programs
  (1..SIZE).each do |ind|
    Program.
      where(:slug => "REG#{ind}").
      first_or_create!(:title => "Reg #{ind}")
  end

  prog1 = Program.find_by_slug('REG1')
  prog2 = Program.find_by_slug('REG2')

  prog1.object_people.
    where(:role => :owner).
    first_or_create!(:person => account_person1)

  prog2.object_people.
    where(:role => :owner).
    first_or_create!(:person => account_person2)

  # Sections
  co = Section.
    where(:slug => 'REG1-CO1').
    first_or_create!(
      {:title => 'CO 1', :description => 'x', :program => prog1},
      :without_protection => true)

  # Controls
  ctl = Control.
    where(:slug => 'REG1-CTL1').
    first_or_create!(
      {:title => 'Control 1', :description => 'x', :program => prog2,
      :is_key => true, :fraud_related => false},
      :without_protection => true)
  (2..SIZE).each do |ind|
    Control.
      where(:slug => "REG2-CTL#{ind}").
      first_or_create!(:title => "Control #{ind}", :program => prog2)
  end

  company_ctl = Control.
    where(:slug => 'COM-CTL1').
    first_or_create!(
      {:title => 'Company Control 1', :description => 'x', :program => prog1,
      :is_key => true, :fraud_related => false},
      :without_protection => true)
  cycle = Cycle.
    where(:program_id => prog1).
    first_or_create!(
      {:program_id => prog1, :start_at => '2011-01-01', :complete => false},
      :without_protection => true)

  # People

  person1 = Person.where(:email => 'john@example.com').first_or_create!
  person2 = Person.where(:email => 'jane@example.com').first_or_create!

  sys = System.
    where(:slug => 'SYS1').
    first_or_create!(
      :title => 'System 1', :description => 'x', :infrastructure => true)
  sys.object_people.
    where(:role => 'owner').
    first_or_create!(:person => person2)

  sc = SystemControl.
    where(:control_id => ctl, :system_id => sys, :cycle_id => cycle).
    first_or_create!({}, :without_protection => true)

  # DocumentDescriptor deprecated?
  #desc = DocumentDescriptor.where(:title => 'ACL').first_or_create!
  #company_ctl.evidence_descriptors << desc
  #company_ctl.save

  doc = Document.
    where(:link => 'http://doc1.com/', :title => 'Doc 1').
    first_or_create!

  bp = System.
    where(:slug => 'BP1').
    first_or_create!(:title => 'BP1', :is_biz_process => true, :infrastructure => false)
  bp.sub_system_systems.first_or_create!(:child => sys)
  bp.system_controls.first_or_create!(:control => company_ctl)
  bp.system_sections.first_or_create!(:section => co)
  bp.object_people.first_or_create!(
    {:person => person1, :role => 'owner'}, :without_protection => true)

  # BusinessArea deprecated?
  #biz_area = BusinessArea.where(:title => 'title1').first_or_create!

  # Categories

  # Control categories
  control_categories = [
    ["Access Control", ["Access Management", "Authorization", "Authentication"]],
    ["Change Management", ["Segregation of Duties", "Configuration Management"]],
    ["Business Continuity", ["Disaster Recovery", "Physical Security"]],
    ["Governance", ["Training", "Policies & Procedures", "Monitoring"]]
  ]

  ccats = Category.ctype(Control::CATEGORY_TYPE_ID)
  control_categories.each do |root_name, option_names|
    scat = ccats.where(:name => root_name).first_or_create!
    scats = scat.children.ctype(Control::CATEGORY_TYPE_ID)
    option_names.each do |name|
      scats.where(:name => name).first_or_create!
    end
  end

  ctl.categories << Category.where(:name => 'Authorization').first
  ctl.save

  # Options

  options = {
    :control_type => [],
    :control_kind => ["Reactive", "Directive", "Detective", "Preventative"],
    :control_means => ["Manual", "Manual with Segregation of Duties", "Automated"],
    :system_type => ["Infrastructure"],
    :document_type => [],
    :document_status => [:active, :deprecated],
    :document_year => (1980..2012).to_a.reverse,
    :language => []
  }

  options.each do |k, opts|
    opts.each do |opt|
      Option.where(:role => k.to_s, :title => opt).first_or_create!
    end
  end
end

