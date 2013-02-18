require 'open-uri'
require 'csv'

module Importer
  # Importer for specialized CSV document format
  #
  # Expected columns are:
  #   0-4:  Company control index, unused, title, description-part-1, description-part-2
  #   5-6:  Directive 1: description, slug(s)
  #   7-8:  Directive 2: description, slug(s)
  #   9-10: Directive 3: description, slug(s)
  #
  # Header format (by column) (some unused):
  #   0: "#"
  #   2,3: Company title, slug
  #   5,6: Directive 1 description, slug
  #   7,8: Directive 1 description, slug
  #   9,10: Directive 1 description, slug
  class Consolidated
    attr_accessor :company_controls

    def initialize
      @directives = []
      @company_controls = []
    end

    def run_file(filename)
      open(filename, 'r:utf-8') do |file|
        run_csv(file.read())
      end
    end

    # Create the default Directive objects and iterate rows, creating Controls,
    # Sections, and associated mappings
    def run_csv(csv_string)
      headers_seen = false

      CSV.parse(csv_string) do |row|
        if !headers_seen
          # Still waiting for headers

          # Check for the '#' column
          if row[0] && row[0].match(/#/)
            headers_seen = true

            # Retrieve Directive names and slugs from headers of columns
            add_directive(row[3], row[2], true)  # Required
            add_directive(row[6], row[5])  if row[5].present?
            add_directive(row[8], row[7])  if row[7].present?
            add_directive(row[10], row[9]) if row[9].present?
          end

        else
          # Headers passed, handle row-by-row import

          # Company controls
          if row[0]
            directive = @directives[0]

            slug = "#{directive.slug}.#{row[0]}"
            desc = "Objective:\n#{row[3]}\n\nControl:\n#{row[4]}"

            control = find_or_create(
              Control,
              { :slug => slug },
              { :title => row[2],
                :description => desc,
                :directive => directive })

            @company_controls.push(control)
          end

          # Regulatory Controls
          add_control(@directives[1], row[6],  row[5]) if row[5] && row[6] != "N/A"
          add_control(@directives[2], row[8],  row[7]) if row[7] && row[8] != "N/A"
          add_control(@directives[3], row[10], row[9]) if row[9] && row[10] != "N/A"
        end
      end
    end

    def add_directive(slug, title, is_company=false)
      raise ImportError, "Invalid header row" if !slug.present?

      directive = find_or_create(
        Directive,
        { :slug => slug.strip },
        { :title => title.present? ? title.strip : slug,
          :company => is_company })

      section = find_or_create(
        Section,
        { :slug => slug.strip },
        { :title => title.present? ? title.strip : slug,
          :directive => directive })

      @directives.push(directive)
    end

    # For each slug, create the Control object and mappings
    def add_control(directive, slugs, description)
      slugs.split(',').map(&:strip).each do |slug|
        slug = "#{directive.slug}.#{slug}"
        control = find_or_create(
          Control,
          { :slug => slug },
          { :description => description,
            :title => slug,
            :directive => directive })

        section = Section.where(:slug => slug).first
        section ||= Section.create_in_tree(
          :slug => slug,
          :title => slug,
          :directive => directive)

        control_section = find_or_create(
          ControlSection,
          :control_id => control.id,
          :section_id => section.id)

        control_control = find_or_create(
          ControlControl,
          { :control_id => @company_controls.last.id,
            :implemented_control_id => control.id })
      end
    end

    private

    def find_or_create(model, find_params, create_params=nil)
      instance = model.where(find_params).first
      instance ||= model.create!(find_params.merge(create_params || {}))
      instance
    end
  end
end

