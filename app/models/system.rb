# A system to be audited
class System < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :title, :slug, :description, :url, :version, :infrastructure, :is_biz_process, :type, :start_date, :stop_date

  # Many to many with Control
  has_many :system_controls, :dependent => :destroy
  has_many :controls, :through => :system_controls#, :order => :slug

  # FIXME: Is this still used, or is it deprecated?
  # Many to many with Section
  has_many :system_sections, :dependent => :destroy
  has_many :sections, :through => :system_sections#, :order => :slug

  # Responsible party
  # FIXME: Is this deprecated now? Should we use ObjectPerson?
  belongs_to :owner, :class_name => 'Person'

  has_many :sub_system_systems, :dependent => :destroy,
    :class_name => 'SystemSystem', :foreign_key => 'parent_id'
  has_many :sub_systems,
    :through => :sub_system_systems, :source => 'child'

  has_many :super_system_systems, :dependent => :destroy,
    :class_name => 'SystemSystem', :foreign_key => 'child_id'
  has_many :super_systems,
    :through => :super_system_systems, :source => 'parent'

  has_many :transactions

  belongs_to :type, :class_name => 'Option', :conditions => { :role => 'system_type' }

  is_versioned_ext

  validates :title,
    :presence => { :message => "needs a value" }

  def custom_edges
    # Returns a list of additional edges that aren't returned by the default method.
    # FIXME: A LOT of these do not exist in the current design doc.

    edges = Set.new

    if !owner.nil?
      edges.add(Edge.new(owner, self, :person_owns_system))
    end

    sections.each do |section|
      edges.add(Edge.new(section, self, :section_implemented_by_system))
    end

    controls.each do |control|
      edges.add(Edge.new(control, self, :control_implemented_by_system))
    end

    super_systems.each do |system|
      edges.add(Edge.new(system, self, :system_contains_system))
    end

    sub_systems.each do |system|
      edges.add(Edge.new(self, system, :system_contains_system))
    end

    edges
  end

  def self.custom_all_edges
    # Returns a list of additional edges that aren't returned by the default method.
    # FIXME: A LOT of these do not exist in the current design doc.

    edges = Set.new

    includes(:owner, :sections, :controls, :super_systems, :sub_systems).each do |s|
      if !s.owner.nil?
        edges.add(Edge.new(s.owner, s, :person_owns_system))
      end

      s.sections.each do |section|
        edges.add(Edge.new(section, s, :section_implemented_by_system))
      end

      s.controls.each do |control|
        edges.add(Edge.new(control, s, :control_implemented_by_system))
      end

      s.super_systems.each do |system|
        edges.add(Edge.new(system, s, :system_contains_system))
      end

      s.sub_systems.each do |system|
        edges.add(Edge.new(s, system, :system_contains_system))
      end
    end

    edges
  end

  def display_name
    slug
  end

  # TODO: state(), state_by_process left for reference -- remove after
  # implementing proper object states

  # Rolled up state by biz process
  def state_by_process(bp)
    state(:control_id => bp.controls)
  end

  # Rolled up state
  def state(opts = {})
    scs = system_controls.where(opts)
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

  def default_slug_prefix
    is_biz_process? ? 'PROCESS' : 'SYSTEM'
  end
end
