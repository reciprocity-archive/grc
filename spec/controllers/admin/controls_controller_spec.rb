require 'spec_helper'
require 'base_objects'
require 'authorized_controller'

describe Admin::ControlsController do
  include BaseObjects

  before :each do
    create_base_objects

    # Authorized_controller test setup
    @model = Control
    @index_objs = [@ctl, @ctl2, @ctl3]
    @object = @ctl
    @index_objs = [@ctl]
  end

  it_behaves_like "an admin controller"
  it_behaves_like "an authorized controller"

  describe "authorized" do
    before :each do
      login({}, { :role => 'admin' })
    end

    describe "POST 'create'" do
      it "creates a new object" do
        test_controller_create(:control, :program_id => @reg.id, :title => 'ctlx', :description => 'descx', :slug => "REG1-CX")
      end
    end

    describe "PUT 'update'" do
      it "updates an existing object" do
        @ctl.sections.should eq([])
        test_controller_update(:control, @ctl, :description => "desc2", :section_ids => [@sec.id])
        @ctl.reload
        @ctl.sections.should eq([@sec])
      end
    end
  end

end
