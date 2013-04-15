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

  # Directives
  (1..SIZE).each do |ind|
    Directive.
      where(:slug => "REG#{ind}").
      first_or_create!(:title => "Reg #{ind}")
  end

  prog1 = Directive.find_by_slug('REG1')
  prog2 = Directive.find_by_slug('REG2')

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
      {:title => 'CO 1', :description => 'x', :directive => prog1},
      :without_protection => true)

  # Controls
  ctl = Control.
    where(:slug => 'REG1-CTL1').
    first_or_create!(
      {:title => 'Control 1', :description => 'x', :directive => prog2},
      :without_protection => true)

  company = Directive.find_by_slug('COMPANY')
  ctl = Control.find_or_create_by_slug!({
    :slug => 'COMPANY-EVIL',
    :title => 'Be less evil',
    :description => 'Reduce the quantity and quality of evil',
    :directive => company
  })

  ctl = Control.
    where(:slug => 'REG1-CTL1').
    first_or_create!(
      {:title => 'Control 1', :description => 'x', :directive => prog2},
      :without_protection => true)

  ctl.categories << Category.where(:name => 'Authorization').first
  ctl.save

  (2..SIZE).each do |ind|
    Control.
      where(:slug => "REG2-CTL#{ind}").
      first_or_create!(:title => "Control #{ind}", :directive => prog2)
  end

  company_ctl = Control.
    where(:slug => 'COM-CTL1').
    first_or_create!(
      {:title => 'Company Control 1', :description => 'x', :directive => prog1},
      :without_protection => true)

  # FIXME: Cycles now relate to programs
  #cycle = Cycle.
  #  where(:directive_id => prog1).
  #  first_or_create!(
  #    {:title => 'Audit 1', :directive => prog1, :start_at => '2011-01-01', :complete => false},
  #    :without_protection => true)

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

  # FIXME: Fix when cycle is fixed above
  #sc = SystemControl.
  #  where(:control_id => ctl, :system_id => sys, :cycle_id => cycle).
  #  first_or_create!({}, :without_protection => true)

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

    # Create business objects - org groups, products, facilities
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

    loc = Facility.
      where(:slug => 'FACILITY-SEED1').
      first_or_create!({
          :slug => 'FACILITY-SEED1',
          :title => "Facility 1", :description => 'A Facility'},
        :without_protection => true
      )

    loc2 = Facility.
      where(:slug => 'FACILITY-SEED2').
      first_or_create!({
          :slug => 'FACILITY-SEED2',
          :title => "Facility 2", :description => 'Another facility'},
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
      where(:relationship_type_id => 'org_group_has_province_over_facility',
        :source_type => org.class.to_s,
        :source_id => org.id,
        :destination_type => loc.class.to_s,
        :destination_id => loc.id).
      first_or_create!({
          :relationship_type_id => 'org_group_has_province_over_facility',
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
      where(:relationship_type_id => 'org_group_is_dependent_on_facility',
        :source_type => org.class.to_s,
        :source_id => org.id,
        :destination_type => loc2.class.to_s,
        :destination_id => loc2.id).
      first_or_create!({
          :relationship_type_id => 'org_group_is_dependent_on_facility',
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
      where(:relationship_type_id => 'directive_is_relevant_to_org_group',
        :source_type => prog1.class.to_s,
        :source_id => prog1.id,
        :destination_type => org.class.to_s,
        :destination_id => org.id).
      first_or_create!({
          :relationship_type_id => 'directive_is_relevant_to_org_group',
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
      where(:relationship_type_id => 'product_is_dependent_on_facility',
        :source_type => prod.class.to_s,
        :source_id => prod.id,
        :destination_type => loc.class.to_s,
        :destination_id => loc.id).
      first_or_create!({
          :relationship_type_id => 'product_is_dependent_on_facility',
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
      where(:relationship_type_id => 'directive_is_relevant_to_product',
        :source_type => prog1.class.to_s,
        :source_id => prog1.id,
        :destination_type => prod.class.to_s,
        :destination_id => prod.id).
      first_or_create!({
          :relationship_type_id => 'directive_is_relevant_to_product',
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
      where(:relationship_type_id => 'market_is_dependent_on_facility',
        :source_type => market.class.to_s,
        :source_id => market.id,
        :destination_type => loc.class.to_s,
        :destination_id => loc.id).
      first_or_create!({
          :relationship_type_id => 'market_is_dependent_on_facility',
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
