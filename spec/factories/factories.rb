FactoryGirl.define do
  sequence(:slug) do |n|
    # FIXME: Do I need to generate slugs according to a convention, or
    # do they only need to be unique?
    # FIXME: Slugs will become invalid if parenting is ever changed
    # anywhere in the ancestor heirarchy.
    # FIXME: Slug validation makes factories for sections tricky. How tied
    # to using slugs are we?
    # FIXME: Maybe change slugs to store the incremental slug
    # and automatically generate the full slug on data change
    # (including changing of parent)
    #



    "SLUG#{n}_#{((Time.now).to_f*1000).to_i}"
  end

  sequence(:username) do |n|
    "User#{n}"
  end

  sequence(:content) do |n|
    "Content#{n}"
  end

  sequence(:title) do |n|
    "Title#{n}"
  end

  sequence(:email) do |n|
    "user#{n}@example.com"
  end

  factory :program do
    ignore do
      num_people 3
      num_sections 3
    end

    title 'Program'
    slug

    trait :with_people do
      after(:create) do |prog, evaluator|
        (1..evaluator.num_people).to_a.map do
          person = FactoryGirl.create(:person)
          FactoryGirl.create(:object_person, :person => person, :personable => prog)
        end
      end
    end

    trait :with_sections do
      after(:create) do |prog, evaluator|
        section = FactoryGirl.create_list(:section, evaluator.num_sections, program: prog)
      end
    end

    trait :with_sections_with_children do
      after(:create) do |prog, evaluator|
        (1..evaluator.num_sections).to_a.map do
          section = FactoryGirl.create(:section_with_children,
                                       { program: prog })
        end
      end
    end
  end

  factory :account do
    email
    password 'password'
    password_confirmation 'password'
    role 'default'
  end

  factory :person do
    email
  end

  factory :section do
    title 'Section'
    slug
    program

    factory :section_with_ancestors do
      ignore do
        ancestor_depth 3
      end

      # FIXME: Make all sections have the same program
      parent do |s|
        if s.ancestor_depth > 0
          s.association(:section_with_ancestors,
                        { ancestor_depth: s.ancestor_depth - 1,
                          program: s.program })
        end
      end
    end

    factory :section_with_children do |sec|
      ignore do
        ancestor_depth 3
        parent_slug "SLUG"
      end

      slug do |s|
        s.parent_slug + '-' + FactoryGirl.generate(:slug)
      end

      # FIXME: Make all sections have the same program
      parent do |s|
        if s.ancestor_depth > 0
          s.association(:section_with_children, ancestor_depth: s.ancestor_depth - 1, parent_slug: sec.slug)
        end
      end
    end
  end

  factory :control do
    # FIXME: program should not be required, as there may be multiple "parent"
    # programs via different sections

    title 'Factory Control'
    slug
    program
    description 'x'

    factory :control_with_child_controls do
      #implemented_controls { |c| [c.association(:leaf_control)] }

      ignore do
        child_depth 1
        child_count 3
      end

      implemented_controls do |c|
        if c.child_depth == 0
          []
        else
          (1..c.child_count).to_a.map do
            c.association(:control_with_child_controls, child_depth: c.child_depth - 1)
          end
        end
      end
    end

    factory :control_with_ancestor_sections do
      #implemented_controls { |c| [c.association(:leaf_control)] }

      ignore do
        ancestor_depth 1
        section_count 3
      end

      sections do |c|
        if c.ancestor_depth == 0
          []
        else
          (1..c.section_count).to_a.map do
            c.association(:section_with_ancestors, ancestor_depth: c.ancestor_depth - 1)
          end
        end
      end
    end
  end

  factory :system do
    title 'Factory System'
    slug
    description 'x'
    infrastructure false
  end

  factory :product do
    slug
    title
  end
  
  factory :org_group do
    title
  end

  factory :location do
    title
  end

  factory :market do
    title
  end

  factory :risky_attribute do
    title
  end

  factory :help do
    slug
    content
  end

  factory :relationship_type do
  end
  factory :relationship do
    source { |c| c.association(:program) }
    destination { |c| c.association(:product) }
  end

  factory :control_section do
    control
    section
  end

  factory :control_control do
    control
    implemented_control { |c| c.association(:control) }
  end

  factory :category
  factory :categorization do
    category
    categorizable { |c| c.association(:system) }
  end

  factory :cycle do
    complete false
    start_at '2012-01-01'
    program { |c| c.association(:program) }
  end

  factory :document do
    title 'document'
  end

  factory :system_control do
    system
    control
  end

  factory :system_section do
    system
    section
  end

  factory :object_document do
    document
    documentable { |c| c.association(:system) }
  end

  factory :system_system do
    parent { |c| c.association(:system) }
    child { |c| c.association(:system) }
  end

  factory :transaction do
    title 'transaction x'
    description 'x'
  end

  factory :option do
    description 'x'
    title 'option x'
    role 'default'
  end

  factory :object_person do
    role "default"
    personable { |c| c.association(:system) }
    person
  end

end
