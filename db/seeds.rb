# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#

Account.create(:email => 'root@t.com', :password => 'root', :password_confirmation => 'root', :role => :superuser)
Account.create(:email => 'admin@t.com', :password => 'admin', :password_confirmation => 'admin', :role => :admin)
Account.create(:email => 'user@t.com', :password => 'user', :password_confirmation => 'user', :role => :analyst)
reg = Program.create(:title => 'Reg 1', :slug => 'REG1', :company => false)
company_reg = Program.create(:title => 'Company', :slug => 'COM', :company => true)
co = Section.create(:title => 'CO 1', :slug => 'REG1-CO1', :description => 'x', :program => reg)
ctl = Control.create(:title => 'Control 1', :slug => 'REG1-CTL1', :description => 'x', :program => reg, :is_key => true, :fraud_related => false)
company_ctl = Control.create(:title => 'Company Control 1', :slug => 'COM-CTL1', :description => 'x', :program => company_reg, :is_key => true, :fraud_related => false)
cycle = Cycle.create(:program => reg, :start_at => '2011-01-01')
company_co = Section.create(:title => 'Company CO 1', :slug => 'COM-CO1', :description => 'x', :program => company_reg)
person1 = Person.create(:username => 'john')
person2 = Person.create(:username => 'jane')
sys = System.create(:title => 'System 1', :slug => 'SYS1', :description => 'x', :infrastructure => true)
sys.owner = person2
sys.save
sc = SystemControl.create(:control => company_ctl, :system => sys, :cycle => cycle)
desc = DocumentDescriptor.create(:title => 'ACL')
company_ctl.evidence_descriptors << desc
company_ctl.save
doc = Document.create(:link => 'http://cde.com/', :title => 'Cde')
bp = BizProcess.create(:title => 'BP1', :slug => 'BP1')
bp.systems << sys
bp.controls << company_ctl
bp.sections << company_co
bp.save
biz_area = BusinessArea.create(:title => 'title1')
sys_person1 = SystemPerson.create(:person => person1, :system => sys)
bp_person1 = BizProcessPerson.create(:person => person1, :biz_process => bp)

ccats = Category.ctype(Control::CATEGORY_TYPE_ID)
ac_cat = ccats.create(:name => 'Access Control')
ac_cats = ac_cat.children.ctype(Control::CATEGORY_TYPE_ID)
ac_cats.create(:name => 'Access Management')
ac_cats.create(:name => 'Authorization')
ac_cats.create(:name => 'Authentication')
cm_cat = ccats.create(:name => 'Change Management')
cm_cats = cm_cat.children.ctype(Control::CATEGORY_TYPE_ID)
cm_cats.create(:name => 'Segregation of Duties')
cm_cats.create(:name => 'Configuration Management')
