# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#

SIZE=20

Account.create({:email => 'root@t.com', :password => 'root', :password_confirmation => 'root', :role => :superuser}, :without_protection => true)
Account.create({:email => 'admin@t.com', :password => 'admin', :password_confirmation => 'admin', :role => :admin}, :without_protection => true)
Account.create({:email => 'user@t.com', :password => 'user', :password_confirmation => 'user', :role => :analyst}, :without_protection => true)
prog = Program.create(:title => 'Reg 1', :slug => 'REG1')
(2..SIZE).each do |ind|
  Program.create(:title => "Reg #{ind}", :slug => "REG#{ind}")
end
co = Section.create({:title => 'CO 1', :slug => 'REG1-CO1', :description => 'x', :program => prog}, :without_protection => true)
ctl = Control.create({:title => 'Control 1', :slug => 'REG1-CTL1', :description => 'x', :program => prog, :is_key => true, :fraud_related => false}, :without_protection => true)
(2..SIZE).each do |ind|
  Control.create(:title => "Control #{ind}", :slug => "REG2-CTL#{ind}")
end
company_ctl = Control.create({:title => 'Company Control 1', :slug => 'COM-CTL1', :description => 'x', :program => prog, :is_key => true, :fraud_related => false}, :without_protection => true)
cycle = Cycle.create({:program_id => prog, :start_at => '2011-01-01', :complete => false}, :without_protection => true)
person1 = Person.create(:username => 'john')
person2 = Person.create(:username => 'jane')
sys = System.create(:title => 'System 1', :slug => 'SYS1', :description => 'x', :infrastructure => true)
sys.owner = person2
sys.save
sc = SystemControl.create({:control_id => ctl, :system_id => sys, :cycle_id => cycle}, :without_protection => true)
desc = DocumentDescriptor.create(:title => 'ACL')
company_ctl.evidence_descriptors << desc
company_ctl.save
doc = Document.create(:link => 'http://cde.com/', :title => 'Cde')
bp = BizProcess.create(:title => 'BP1', :slug => 'BP1')
bp.systems << sys
bp.controls << company_ctl
bp.sections << co
bp.save
biz_area = BusinessArea.create(:title => 'title1')
sys_person1 = SystemPerson.create({:person_id => person1, :system_id => sys}, :without_protection => true)
bp_person1 = BizProcessPerson.create({:person_id => person1, :biz_process_id => bp}, :without_protection => true)

ccats = Category.ctype(Control::CATEGORY_TYPE_ID)
ac_cat = ccats.create(:name => 'Access Control')
ac_cats = ac_cat.children.ctype(Control::CATEGORY_TYPE_ID)
ac_cats.create(:name => 'Access Management')
cauth = ac_cats.create(:name => 'Authorization')
ac_cats.create(:name => 'Authentication')
cm_cat = ccats.create(:name => 'Change Management')
cm_cats = cm_cat.children.ctype(Control::CATEGORY_TYPE_ID)
cm_cats.create(:name => 'Segregation of Duties')
cm_cats.create(:name => 'Configuration Management')

ctl.categories << cauth
ctl.save
