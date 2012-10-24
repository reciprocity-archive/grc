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
      {:title => 'Control 1', :description => 'x', :program => prog2},
      :without_protection => true)
  (2..SIZE).each do |ind|
    Control.
      where(:slug => "REG2-CTL#{ind}").
      first_or_create!(:title => "Control #{ind}", :program => prog2)
  end

  company_ctl = Control.
    where(:slug => 'COM-CTL1').
    first_or_create!(
      {:title => 'Company Control 1', :description => 'x', :program => prog1},
      :without_protection => true)
  cycle = Cycle.
    where(:program_id => prog1).
    first_or_create!(
      {:program => prog1, :start_at => '2011-01-01', :complete => false},
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
    :audit_frequency => [
      'Continuous', 'Ad-Hoc', 'Hourly', 'Daily', 'Weekly',
      'Monthly', 'Quarterly', 'Semi-Annual', 'Annual', 'Bi-Annual'],
    :verify_frequency => [
      'Continuous', 'Ad-Hoc', 'Hourly', 'Daily', 'Weekly',
      'Monthly', 'Quarterly', 'Semi-Annual', 'Annual', 'Bi-Annual'],
    :audit_duration => [
      '1 Week', '2 Weeks', '1 Month', '2 Months', '3 Months',
      '4 Months', '6 Months', '1 Year'],
    #:control_type => ['Regulation', 'Company'],
    :control_kind => ['Reactive', 'Directive', 'Detective', 'Preventative'],
    :control_means => ['Manual', 'Manual with Segregation of Duties', 'Automated'],
    :document_type => ['URL', 'PDF', 'Text', 'Excel', 'Word'],
    :document_status => [:active, :deprecated],
    :document_year => (1980..2012).to_a.map(&:to_s).reverse,
    :language => [],
    #:program_type => ['Regulation', 'Company'],
    :program_kind => ['Not Applicable'],
    #:system_type => ['System', 'Business Process'],
    :system_kind => ['Infrastructure'],
    :product_type => ['Appliance', 'Desktop Software', 'SaaS'],
    :product_kind => ['Not Applicable'],
    :entity_type => [
      'Division', 'Functional Group', 'Business Unit', 'Legal Entity'],
    :entity_kind => ['Not Applicable'],
    :location_type => [
      'Headquarters', 'Regional Office', 'Sales Office',
      'Data Center', 'Colo Data Center', 'Vendor Worksite',
      'Contract Manufacturer', 'Distribution Center'],
    :location_kind => [
      'Building', 'Machine Room', 'Kitchen', 'Workshop', 'Office',
      'HazMat Storage', 'Maintenance Facility', 'Parking Garage', 'Lab'],
    :threat_type => ['Insider Threat', 'Outsider Threat'],
    :asset_type => [
      'Ledger Accounts', 'User Data', 'Personal Identifiable Info',
      'Source Code', 'Patents', 'Client List', 'Employee List'],
    :reference_type => [
      'Website', 'Screenshot', 'Simple Text', 'Document',
      'Numeric Data', 'Database'],
  }

  options.each do |k, opts|
    opts.each do |opt|
      Option.where(:role => k.to_s, :title => opt).first_or_create!
    end
  end

  # Create the default relationship types
  DefaultRelationshipTypes.create_only

  # Create business objects - org groups, products, locations
  # And relationships to other objects

  org = OrgGroup.
    where(:slug => 'ORGGROUP-SEED1').
    first_or_create!({
        :slug => 'ORGGROUP-SEED1',
        :title => "Org Group 1", :description => 'An org group'},
      :without_protection => true
    )

  org2 = OrgGroup.
    where(:slug => 'ORGGROUP-SEED2').
    first_or_create!({
        :slug => 'ORGGROUP-SEED2',
        :title => "Org Group 2", :description => 'Another org group'},
      :without_protection => true
    )

  prod = Product.
    where(:slug => 'PRODUCT-SEED1').
    first_or_create!({
        :slug => 'PRODUCT-SEED1',
        :title => "Product 1", :description => 'A Product'},
      :without_protection => true
    )

  prod2 = Product.
    where(:slug => 'PRODUCT-SEED2').
    first_or_create!({
        :slug => 'PRODUCT-SEED2',
        :title => "Product 2", :description => 'Another Product'},
      :without_protection => true
    )

  prod3 = Product.
    where(:slug => 'PRODUCT-SEED3').
    first_or_create!({
        :slug => 'PRODUCT-SEED3',
        :title => "Product 3", :description => 'Required product'},
      :without_protection => true
    )

  loc = Location.
    where(:slug => 'LOCATION-SEED1').
    first_or_create!({
        :slug => 'LOCATION-SEED1',
        :title => "Location 1", :description => 'A Location'},
      :without_protection => true
    )

  loc2 = Location.
    where(:slug => 'LOCATION-SEED2').
    first_or_create!({
        :slug => 'LOCATION-SEED2',
        :title => "Location 2", :description => 'Another location'},
      :without_protection => true
    )

  market = Market.
    where(:slug => 'MARKET-SEED1').
    first_or_create!({
        :slug => 'MARKET-SEED1',
        :title => "Market 1", :description => 'A Market'},
      :without_protection => true
    )

  market2 = Market.
    where(:slug => 'MARKET-SEED2').
    first_or_create!({
        :slug => 'MARKET-SEED2',
        :title => "Market 2", :description => 'Another market'},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'org_group_has_province_over_location',
      :source_type => org.class.to_s,
      :source_id => org.id,
      :destination_type => loc.class.to_s,
      :destination_id => loc.id).
    first_or_create!({
        :relationship_type_id => 'org_group_has_province_over_location',
        :source => org,
        :destination => loc},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'org_group_is_affiliated_with_org_group',
      :source_type => org.class.to_s,
      :source_id => org.id,
      :destination_type => org2.class.to_s,
      :destination_id => org2.id).
    first_or_create!({
        :relationship_type_id => 'org_group_is_affiliated_with_org_group',
        :source => org,
        :destination => org2},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'org_group_is_dependent_on_location',
      :source_type => org.class.to_s,
      :source_id => org.id,
      :destination_type => loc2.class.to_s,
      :destination_id => loc2.id).
    first_or_create!({
        :relationship_type_id => 'org_group_is_dependent_on_location',
        :source => org,
        :destination => loc2},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'org_group_has_province_over_product',
      :source_type => org.class.to_s,
      :source_id => org.id,
      :destination_type => prod.class.to_s,
      :destination_id => prod.id).
    first_or_create!({
        :relationship_type_id => 'org_group_has_province_over_product',
        :source => org,
        :destination => prod},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'program_is_relevant_to_org_group',
      :source_type => prog1.class.to_s,
      :source_id => prog1.id,
      :destination_type => org.class.to_s,
      :destination_id => org.id).
    first_or_create!({
        :relationship_type_id => 'program_is_relevant_to_org_group',
        :source => prog1,
        :destination => org},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'product_is_affiliated_with_product',
      :source_type => prod.class.to_s,
      :source_id => prod.id,
      :destination_type => prod2.class.to_s,
      :destination_id => prod2.id).
    first_or_create!({
        :relationship_type_id => 'product_is_affiliated_with_product',
        :source => prod,
        :destination => prod2},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'product_is_dependent_on_location',
      :source_type => prod.class.to_s,
      :source_id => prod.id,
      :destination_type => loc.class.to_s,
      :destination_id => loc.id).
    first_or_create!({
        :relationship_type_id => 'product_is_dependent_on_location',
        :source => prod,
        :destination => loc},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'product_is_dependent_on_product',
      :source_type => prod3.class.to_s,
      :source_id => prod3.id,
      :destination_type => prod.class.to_s,
      :destination_id => prod.id).
    first_or_create!({
        :relationship_type_id => 'product_is_dependent_on_product',
        :source => prod3,
        :destination => prod},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'program_is_relevant_to_product',
      :source_type => prog1.class.to_s,
      :source_id => prog1.id,
      :destination_type => prod.class.to_s,
      :destination_id => prod.id).
    first_or_create!({
        :relationship_type_id => 'program_is_relevant_to_product',
        :source => prog1,
        :destination => prod},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'market_contains_a_market',
      :source_type => market.class.to_s,
      :source_id => market.id,
      :destination_type => market2.class.to_s,
      :destination_id => market2.id).
    first_or_create!({
        :relationship_type_id => 'market_contains_a_market',
        :source => market,
        :destination => market2},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'market_is_dependent_on_location',
      :source_type => market.class.to_s,
      :source_id => market.id,
      :destination_type => loc.class.to_s,
      :destination_id => loc.id).
    first_or_create!({
        :relationship_type_id => 'market_is_dependent_on_location',
        :source => market,
        :destination => loc},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'org_group_has_province_over_market',
      :source_type => org.class.to_s,
      :source_id => org.id,
      :destination_type => market.class.to_s,
      :destination_id => market.id).
    first_or_create!({
        :relationship_type_id => 'org_group_has_province_over_market',
        :source => org,
        :destination => market},
      :without_protection => true
    )

  Relationship.
    where(:relationship_type_id => 'product_is_sold_into_market',
      :source_type => prod.class.to_s,
      :source_id => prod.id,
      :destination_type => market.class.to_s,
      :destination_id => market.id).
    first_or_create!({
        :relationship_type_id => 'product_is_sold_into_market',
        :source => prod,
        :destination => market},
      :without_protection => true
    )

end
