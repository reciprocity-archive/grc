class QuickController < ApplicationController
  layout nil

  def programs
    @programs = Program
    if params[:s]
      @programs = @programs.search(params[:s])
    end
    @programs = @programs.all
  end

  def sections
    @sections = Section
    if params[:s]
      @sections = @sections.search(params[:s])
    end
    @sections = @sections.all
  end

  def controls
    @controls = Control
    if params[:s]
      @controls = @controls.search(params[:s])
    end
    @controls = @controls.all
  end
end
