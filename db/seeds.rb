# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

ActiveRecord::Base.transaction do

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

  # Control assertions

  control_assertions = [
    "Accuracy", "Classification", "Completeness", "Cutoff", "Existence",
    "Occurrence", "Rights and Obligations", "Valuation and Allocation",
    "Understandability"
  ]

  acats = Category.ctype(Control::CATEGORY_ASSERTION_TYPE_ID)
  control_assertions.each do |name|
    acats.where(:name => name).first_or_create!
  end

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
    :control_kind => ['Reactive', 'Administrative', 'Detective', 'Preventative'],
    :control_means => ['Manual', 'Manual w Segregation of Duties', 'Automated'],
    :document_type => ['URL', 'PDF', 'Text', 'Excel', 'Word'],
    :document_status => [:active, :deprecated],
    :document_year => (1980..2012).to_a.map(&:to_s).reverse,
    :language => ['English'],
    #:directive_kind => ['Regulation', 'Company Policy', 'Operational Group Policy', 'Data Asset Policy', 'Company Controls'],
    #:system_type => ['System', 'Process'],
    :system_kind => ['Infrastructure'],
    :product_type => ['Appliance', 'Desktop Software', 'SaaS'],
    :product_kind => ['Not Applicable'],
    :entity_type => [
      'Division', 'Functional Group', 'Business Unit', 'Legal Entity'],
    :entity_kind => ['Not Applicable'],
    :facility_type => [
      'Headquarters', 'Regional Office', 'Sales Office',
      'Data Center', 'Colo Data Center', 'Vendor Worksite',
      'Contract Manufacturer', 'Distribution Center'],
    :facility_kind => [
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

  # FIXME: RelationshipType table is not currently used
  # Create the default relationship types
  #DefaultRelationshipTypes.create_only

  Directive.find_or_create_by_slug!({
    :slug => 'COMPANY',
    :title => 'Company Controls',
    :company => true,
    :kind => Option.options_for(:directive_kind).find_by_title('Company Controls')
  })
end
