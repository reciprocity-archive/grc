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

    "SLUG#{n}"
  end

  sequence(:username) do |n|
    "User#{n}"
  end

  factory :program do
    title 'Program'
    slug

    factory :program_with_people do
      ignore do
        num_people 3
      end
      after(:create) do |prog, evaluator|
        (1..evaluator.num_people).to_a.map do
          person = FactoryGirl.create(:person)
          FactoryGirl.create(:object_person, :person => person, :personable => prog)
        end
      end
    end
  end

  factory :person do
    username
  end

  factory :object_person do
    role "default"
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
          s.association(:section_with_ancestors, ancestor_depth: s.ancestor_depth - 1)
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
end
