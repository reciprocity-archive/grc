# A system to be audited
class System < ActiveRecord::Base
  include CommonModel
  include SluggedModel
  include SearchableModel
  include AuthorizedModel
  include RelatedModel
  include SanitizableAttributes
  include DatedModel

  CATEGORY_TYPE_ID = 101

  attr_accessible :title, :slug, :description, :url, :version, :infrastructure, :is_biz_process, :type, :start_date, :stop_date, :notes, :network_zone_id

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
  belongs_to :network_zone, :class_name => 'Option', :conditions => { :role => 'network_zone' }

  has_many :categorizations, :as => :categorizable, :dependent => :destroy
  has_many :categories, :through => :categorizations, :conditions => { :scope_id => System::CATEGORY_TYPE_ID }

  has_many :responses, :dependent => :destroy

  is_versioned_ext

  sanitize_attributes :description, :notes

  validates :title,
    :presence => { :message => "needs a value" }
    
  validates :url, :allow_blank => true, :url => true

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

  # Rolled up state by process
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

  def meta_kind
    is_biz_process? ? :process : :system
  end

  def categories_display
    categories.map {|x| x.name}.join(',')
  end

  def sub_systems_display
    sub_systems.map {|x| x.slug}.join(',')
  end

  def org_groups_display
    rels = Relationship.where(:relationship_type_id => :system_is_a_process_for_org_group, :source_id => self, :source_type => System.name)
    rels.map {|x| x.destination.slug}.join(',')
  end

  def references_display
    documents.map do |d|
      "#{d.description} [#{d.link} #{d.title}]"
    end.join("\n")
  end

  def owner_display
    p = object_people.detect {|x| x.role == 'accountable'}
    p ? p.person.email : ''
  end

  def absolute_url(valid_schemes=%w(http https file), default_scheme='http')
    if url.present? && valid_schemes.include?(url.split(':')[0])
      url
    elsif url.present?
      "#{default_scheme}://#{url}"
    else
      ""
    end
  end

  def as_json(options={})
    super((options || {}).merge :methods => [:absolute_url, :description_inline])
  end
end
