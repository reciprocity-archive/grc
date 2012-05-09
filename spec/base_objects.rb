module BaseObjects
  def create_base_objects
    @reg = Program.create(:title => 'Reg 1', :slug => 'REG1', :company => false)
    @ctl = Control.create(:title => 'Control 1', :slug => 'CTL1', :description => 'x', :program => @reg, :is_key => true, :fraud_related => false)
    @cycle = Cycle.create(:program => @reg, :start_at => '2011-01-01')
    @sec = Section.create(:title => 'Section 1', :slug => 'REG1-SEC1', :description => 'x', :program => @reg)
    @sys = System.create(:title => 'System 1', :slug => 'SYS1', :description => 'x', :infrastructure => true)
    @sc = SystemControl.create(:control => @ctl, :system => @sys, :cycle => @cycle, :state => :green)
    @desc = DocumentDescriptor.create(:title => 'ACL')
    @doc = Document.create(:link => 'http://cde.com/', :title => 'Cde')
    @bp = BizProcess.create(:title => 'BP1', :slug => 'BP1')
    @bp.systems << @sys
    @bp.controls << @ctl
    @bp.sections << @sec
    @biz_area = BusinessArea.create(:title => 'title1')
    @person1 = Person.create(:username => 'john')
    @sys_person1 = SystemPerson.create(:person => @person1, :system => @sys)
    @bp_person1 = BizProcessPerson.create(:person => @person1, :biz_process => @bp)
    #debugger
  end

  def test_controller_index(assign, objs)
    get 'index'
    response.should be_success
    assigns(assign).should eq(objs)
  end

  def test_controller_create(assign, params)
    post 'create', assign => params
    response.should be_redirect
    result = assigns(assign)
    result.changed?.should be_false
    params.each do |key, value|
      result.send(key).should eq(value)
    end
  end

  def test_controller_update(assign, obj, params)
    put 'update', :id => obj.id, assign => params
    response.should be_redirect
    result = assigns(assign)
    result.should eq(obj)
    result.changed?.should be_false
    params.each do |key, value|
      result.send(key).should eq(value)
    end
  end

  def test_unauth
      login({}, {})
      get 'index'
      response.should be_redirect
  end

end
