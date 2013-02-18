require 'open-uri'
require 'csv'

module Importer
  class Regulation

    def initialize
    end

    def run_file(filename)
      open(filename, 'r:utf-8') do |file|
        run_csv(file.read)
      end
    end

    def run_csv(csv_string)
      directive = nil

      headers_seen = false

      CSV.parse(csv_string) do |row|
        # Iterate until we see the header row (denoted by 'slug' in first
        # column), then start row-by-row imports.

        if !headers_seen
          # Still waiting for headers

          # Check for the 'Slug' header
          if row[0] && row[0].match(/slug/i)
            headers_seen = true
            next

          # We're still in metadata mode
          elsif row[0] && row[0].match(/directive/i)
            slug = row[1].strip
            title = row[2].present? ? row[2].strip : slug

            directive = Directive.where(:slug => slug).first
            directive ||= Directive.create(
              :slug => slug,
              :title => title)

            section = Section.create_in_tree(
              :slug => slug,
              :title => title,
              :directive => directive)
          end

        else
          # Headers passed, now doing row-by-row import

          title = row[1]
          if !title.present?
            title = row[2][0,80]
            title += "..." if row[2].size > 80
          end

          description = row[2].strip

          # For now, append notes to the description field
          description += "\n\nNotes:\n#{row[3].strip}" if row[3].present?

          section = Section.where(:slug => row[0].strip).first
          section ||= Section.create_in_tree(
            :slug => row[0].strip,
            :title => title,
            :description => description,
            :directive => directive)
        end
      end

    end
  end
end

