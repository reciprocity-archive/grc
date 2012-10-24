# A system to be audited
class System < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel

  attr_accessible :title, :slug, :description, :infrastructure, :is_biz_process, :type

  # Many to many with Control
  has_many :system_controls, :dependent => :destroy
  has_many :controls, :through => :system_controls, :order => :slug

  # FIXME: Is this still used, or is it deprecated?
  # Many to many with Section
  has_many :system_sections, :dependent => :destroy
  has_many :sections, :through => :system_sections, :order => :slug

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

    edges = []

    if !owner.nil?
      edge = {
        :source => owner,
        :destination => self,
        :type => :person_owns_system
      }
    end

    sections.each do |section|
      edge = {
        :source => section,
        :destination => self,
        :type => :section_implemented_by_system
      }
      edges.push(edge)
    end
    
    controls.each do |control|
      edge = {
        :source => control,
        :destination => self,
        :type => :control_implemented_by_system
      }
      edges.push(edge)
    end

    super_systems.each do |system|
      edge = {
        :source => system,
        :destination => self,
        :type => :system_contains_system
      }
      edges.push(edge)
    end

    sub_systems.each do |system|
      edge = {
        :source => self,
        :destination => system,
        :type => :system_contains_system
      }
      edges.push(edge)
    end

    edges
  end

  def display_name
    slug
  end

  def authorizing_objects
    # FIXME: Make sure this is the right set of objects
    # to do authorization through.
    aos = Set.new
    aos.add(self)
    #aos.add(program)
    #
    #if (parent)
    #  aos.merge(parent.authorizing_objects)
    #end

    aos
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
end
