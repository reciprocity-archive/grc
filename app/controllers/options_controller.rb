# Author:: Slobodan Kovacevic (mailto:basti@reciprocitynow.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class OptionsController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#  end

  layout 'dashboard'

  def index
    @options = Option.all
    if params[:s].present?
      @options = @options.db_search(params[:s])
    end

    if params[:quick]
      render :partial => 'quick', :locals => { :quick_result => params[:qr]}
    else
      render :json => @options.all.as_json
    end
  end

  def export
    respond_to do |format|
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"options.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(Option.attribute_names)

          Option.all.sort_by(&:role).group_by(&:role).each do |role, options_for_role|
            options_for_role.sort_by(&:title).each do |option|
              out << CSV.generate_line(option.attributes.values)
            end
          end
        end
      end
    end
  end

end
