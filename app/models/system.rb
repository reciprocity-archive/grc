# A system to be audited
class System
  include DataMapper::Resource
  include SluggedModel
  extend SluggedModel::ClassMethods

  before :save, :upcase_slug

  property :id, Serial
  property :title, String, :required => true
  property :slug, String, :required => true
  property :infrastructure, Boolean, :required => true
  property :description, Text

  # Many to many with Control
  has n, :system_controls
  has n, :controls, :through => :system_controls, :order => :slug

  # Many to many with CO
  has n, :system_control_objectives
  has n, :control_objectives, :through => :system_control_objectives, :order => :slug

  # Many to many with BizProcess
  has n, :biz_process_systems
  has n, :biz_processes, :through => :biz_process_systems, :order => :slug

  # Responsible party
  belongs_to :owner, 'Person', :required => false

  # Relevant documentation
  has n, :documents, :through => Resource
  #has n, :supported_systems, "System", :through => Resource

  property :created_at, DateTime
  property :updated_at, DateTime

  is_versioned :on => [:updated_at]

  # Which systems can be attached to a control
  def self.for_control(c)
    all(:order => :slug)
  end

  # Which systems can be attached to a control objective
  def self.for_control_objective(co)
    all(:order => :slug)
  end

  # Which systems can be attached to a biz process
  def system_controls_by_process(bp)
    system_controls.all(:control => bp.controls)
  end

  # Rolled up state by biz process
  def state_by_process(bp)
    state(:control => bp.controls)
  end

  # Rolled up state
  def state(opts = {})
    scs = system_controls.all(opts)
    bad = 0
    count = 0
    res = [:green, ControlState::STATE_WEIGHT[:green]]
    res = scs.inject(res) do |memo, obj|
      count = count + 1
      if !ControlState::STATE_IS_GOOD[obj.state]
        bad = bad + 1
      end
      weight = ControlState::STATE_WEIGHT[obj.state]
      if weight > memo[1]
        [obj.state, weight]
      else
        memo
      end
    end
    return { :state => res[0], :count => count, :bad => bad }
  end

  def display_name
    slug
  end

  # Return ids of related Controls (used by many2many widget)
  def control_ids
    controls.map { |c| c.id }
  end

  # Return ids of related Biz Processes (used by many2many widget)
  def biz_process_ids
    biz_processes.map { |bp| bp.id }
  end

  # Return ids of related COs (used by many2many widget)
  def control_objective_ids
    control_objectives.map { |co| co.id }
  end
end
