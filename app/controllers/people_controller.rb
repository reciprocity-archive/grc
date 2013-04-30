# Author:: Miron Cuperman (mailto:miron+cms@google.com)
# Copyright:: Google Inc. 2012
# License:: Apache 2.0

class PeopleController < BaseObjectsController

#  access_control :acl do
#    allow :superuser
#
#    actions :index do
#      allow :read, :read_person
#    end
#
#    actions :new, :create do
#      allow :create, :create_person
#    end
#
#    actions :edit, :update do
#      allow :update, :update_person, :of => :person
#    end
#
#    actions :destroy do
#      allow :delete, :delete_person, :of => :person
#    end
#  end

  layout 'dashboard'

  no_base_action :tooltip

  def index
    @people = Person
    if params[:s].present?
      @people = @people.db_search(params[:s])
    end
    @people = allowed_objs(@people.all, :read)

    if params[:list_select].present?
      render :partial => 'list_select', :layout => 'layouts/list_select_modal', :locals => {}
    elsif params[:quick]
      render :partial => 'quick', :locals => { :quick_result => params[:qr]}
    else
      render :json => @people
    end
  end

  private

    def extra_delete_relationship_stats
      ObjectPerson.where(:person_id => @person.id).all.map do |op|
        [op.personable_type, op.personable]
      end
    end

    def person_params
      person_params = params[:person] || {}
      language_id = person_params.delete(:language_id)
      if language_id
        language = Option.where(:role => 'person_language', :id => language_id).first
        if language
          person_params[:language] = language
        end
      end
      person_params
    end
end
