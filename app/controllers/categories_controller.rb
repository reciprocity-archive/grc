# Author:: Daniel Ring (mailto:danring+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class CategoriesController < BaseObjectsController

  access_control :acl do
    allow :superuser
  end

  layout 'dashboard'

  no_base_action :tooltip

  def index
    @categories = Category.where(Category.arel_table[:parent_id].not_eq(nil))
    if params[:s]
      @categories = @categories.db_search(params[:s])
    end
    render :json => @categories.all.as_json
  end

  def export
    respond_to do |format|
      format.csv do
        self.response.headers['Content-Type'] = 'text/csv'
        headers['Content-Disposition'] = "attachment; filename=\"categories.csv\""
        self.response_body = Enumerator.new do |out|
          out << CSV.generate_line(Category.attribute_names)

          Category.roots.sort_by(&:display_name).each do |root_category|
            out << CSV.generate_line(root_category.attributes.values)
            root_category.children.sort_by(&:display_name).each do |category|
              out << CSV.generate_line(category.attributes.values)
            end
          end
        end
      end
    end
  end

  private

    def new_object
      ccats = Category.ctype(Control::CATEGORY_TYPE_ID)
      @category = ccats.new(category_params)
    end

    def category_params
      category_params = params[:category] || {}
      parent_id = category_params.delete(:parent_id)
      if parent_id
        category_params[:parent] = Category.find(parent_id)
      end
      category_params
    end
end
