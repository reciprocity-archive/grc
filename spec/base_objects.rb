module BaseObjects
  def create_base_objects
    @reg = Regulation.create(:title => 'Reg 1', :slug => 'reg1', :company => false)
    @ctl = Control.create(:title => 'Control 1', :slug => 'reg1-ctl1', :description => 'x', :regulation => @reg, :is_key => true, :fraud_related => false)
    @co = ControlObjective.create(:title => 'CO 1', :slug => 'reg1-co1', :description => 'x', :regulation => @reg)
    @sys = System.create(:title => 'System 1', :slug => 'sys1', :description => 'x', :infrastructure => true)
    @sc = SystemControl.create(:control => @ctl, :system => @sys, :state => :green)
    @desc = DocumentDescriptor.create(:title => 'ACL')
    @doc = Document.create(:link => 'http://cde.com/', :title => 'Cde')
    @bp = BizProcess.create(:title => 'BP1', :slug => 'bp1')
    @bp.systems << @sys
    @bp.controls << @ctl
    @bp.control_objectives << @co
  end
end
