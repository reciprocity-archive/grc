class QuickController < ApplicationController
  layout false

  # FIXME: Do real access control pending refactoring
  #
  #access_control :acl do
  #  allow logged_in # Filtering is done in the controllers/queries
  #end

  def programs
    @programs = Program
    if params[:s]
      @programs = @programs.search(params[:s])
    end
    @programs = allowed_objs(@programs.all.sort_by(&:slug_split_for_sort), :read)
  end

  def sections
    @sections = Section
    if params[:s]
      @sections = @sections.search(params[:s])
    end
    @sections = allowed_objs(@sections.all.sort_by(&:slug_split_for_sort), :read)
  end

  def controls
    @controls = Control
    if params[:s]
      @controls = @controls.search(params[:s])
    end
    @controls = allowed_objs(@controls.all.sort_by(&:slug_split_for_sort), :read)
  end

  def biz_processes
    @biz_processes = System.where(:is_biz_process => true)
    if params[:s]
      @biz_processes = @biz_processes.search(params[:s])
    end
    @biz_processes = allowed_objs(@biz_processes.all, :read)
  end

  def accounts
    @accounts = Account
    if params[:s]
      @accounts = @accounts.search(params[:s])
    end
    @accounts = allowed_objs(@accounts.all, :read)
  end

  def people
    @people = Person
    if params[:s]
      @people = @people.search(params[:s])
    end
    @people = allowed_objs(@people.all, :read)
  end

  def systems
    @systems = System
    if params[:s]
      @systems = @systems.search(params[:s])
    end
    @systems = allowed_objs(@systems.all, :read)
  end
end
