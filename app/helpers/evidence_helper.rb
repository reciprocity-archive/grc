require 'prawn_monkeypatch'

module EvidenceHelper
  include ApplicationHelper

  # Capture evidence on Google Docs
  #
  # Convert the evidence document to PDF and watermark it with:
  #
  # * Acceptance date
  # * Who accepted the evidence
  # * Which system was the evidence attached to
  #
  # The PDF is then uploaded with the title prefixed with +Evidence+.
  def capture_evidence(doc, system)
    gclient = get_gdata_client
    Tempfile.open('evidence', Rails.root.join('tmp').to_s) do |temp|
      body = gclient.download(doc, 'pdf')
      # TODO: stream the body
      temp.syswrite(body)
      temp.close
      date = display_time(Date.today)
      user = current_user.name
      Tempfile.open('watermark', Rails.root.join('tmp').to_s) do |water|
        Prawn::Document.generate(water.path, :template => temp.path) do
          go_to_page(page_count)
          start_new_page
          create_stamp("evidence") do
            transparent(0.5) do
              rotate(30, :origin => [-250, 250]) do
                fill_color "993333"
                font("Times-Roman") do
                  draw_text "Evidence", :at => [-23, -3], :size => 30
                end
                bounding_box([-34, -20], :width => 140, :height => 140) do
                  text "Accepted: #{date}"
                  text "By: #{user}"
                  text "System: #{system.title} (#{system.slug})"
                  transparent(0.1) { stroke_bounds }
                end
                fill_color "000000"
              end
            end
          end
          repeat :all do
            stamp_at "evidence", [100,200]
          end
        end
        water.close
        return gclient.upload("Evidence - " + doc.title, water.path)
      end
    end
  end
end

