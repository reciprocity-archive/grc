class QuickController < ApplicationController
  layout false

  def programs
    @programs = Program
    if params[:s]
      @programs = @programs.search(params[:s])
    end
    @programs = @programs.all.sort_by(&:slug_split_for_sort)
  end

  def sections
    @sections = Section
    if params[:s]
      @sections = @sections.search(params[:s])
    end
    @sections = @sections.all.sort_by(&:slug_split_for_sort)
  end

  def controls
    @controls = Control
    if params[:s]
      @controls = @controls.search(params[:s])
    end
    @controls = @controls.all.sort_by(&:slug_split_for_sort)
  end

  def biz_processes
    @biz_processes = System.where(:is_biz_process => true)
    if params[:s]
      @biz_processes = @biz_processes.search(params[:s])
    end
    @biz_processes = @biz_processes.all
  end

  def accounts
    @accounts = Account
    if params[:s]
      @accounts = @accounts.search(params[:s])
    end
    @accounts = @accounts.all
  end

  def people
    @people = Person
    if params[:s]
      @people = @people.search(params[:s])
    end
    @people = @people.all
  end

  def systems
    @systems = System
    if params[:s]
      @systems = @systems.search(params[:s])
    end
    @systems = @systems.all
  end
end
