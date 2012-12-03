class QuickController < ApplicationController
  layout false

  # FIXME: Do real access control pending refactoring
  #
  access_control :acl do
    allow logged_in # Filtering is done in the controllers/queries
  end

  def programs
    @programs = Program
    if params[:s].present?
      @programs = @programs.db_search(params[:s])
    end
    @programs = allowed_objs(@programs.all.sort_by(&:slug_split_for_sort), :read)
  end

  def sections
    @sections = Section
    if params[:s].present?
      @sections = @sections.fulltext_search(params[:s])
    end
    @sections = allowed_objs(@sections.all.sort_by(&:slug_split_for_sort), :read)
  end

  def controls
    @controls = Control
    if params[:s].present?
      @controls = @controls.fulltext_search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
  end

  def biz_processes
    @biz_processes = System.where(:is_biz_process => true)
    if params[:s].present?
      @biz_processes = @biz_processes.db_search(params[:s])
    end
    @biz_processes = allowed_objs(@biz_processes.all, :read)
  end

  def accounts
    @accounts = Account
    if params[:s].present?
      @accounts = @accounts.db_search(params[:s])
    end
    @accounts = allowed_objs(@accounts.all, :read)
  end

  def people
    @people = Person
    if params[:s].present?
      @people = @people.db_search(params[:s])
    end
    @people = allowed_objs(@people.all, :read)
  end

  def systems
    @systems = System
    if params[:s].present?
      @systems = @systems.db_search(params[:s])
    end
    @systems = allowed_objs(@systems.all, :read)
  end

  def products
    @products = Product
    if params[:s].present?
      @products = @products.fulltext_search(params[:s])
    end
    @products = allowed_objs(@products.all, :read)
  end
end
