module BaseObjects
  def create_base_objects
    @reg = Regulation.create(:title => 'Reg 1', :slug => 'REG1', :company => false)
    @ctl = Control.create(:title => 'Control 1', :slug => 'REG1-CTL1', :description => 'x', :regulation => @reg, :is_key => true, :fraud_related => false)
    @cycle = Cycle.create(:regulation => @reg, :start_at => '2011-01-01')
    @co = ControlObjective.create(:title => 'CO 1', :slug => 'REG1-CO1', :description => 'x', :regulation => @reg)
    @sys = System.create(:title => 'System 1', :slug => 'SYS1', :description => 'x', :infrastructure => true)
    @sc = SystemControl.create(:control => @ctl, :system => @sys, :cycle => @cycle, :state => :green)
    @desc = DocumentDescriptor.create(:title => 'ACL')
    @doc = Document.create(:link => 'http://cde.com/', :title => 'Cde')
    @bp = BizProcess.create(:title => 'BP1', :slug => 'BP1')
    @bp.systems << @sys
    @bp.controls << @ctl
    @bp.control_objectives << @co
    @biz_area = BusinessArea.create(:title => 'title1')
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
    result.dirty?.should be_false
    params.each do |key, value|
      result.send(key).should eq(value)
    end
  end

  def test_controller_update(assign, obj, params)
    put 'update', :id => obj.id, assign => params
    response.should be_redirect
    result = assigns(assign)
    result.should eq(obj)
    result.dirty?.should be_false
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
