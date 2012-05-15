CmsRails::Application.routes.draw do
  # Admin front page
  match 'admin' => 'admin/base#index'

  # Admin pages
  scope :module => "admin" do
    resources :accounts, :path => "/admin/accounts"
    resources :biz_processes, :path => "/admin/biz_processes" do
      collection do
        get 'controls'
        put 'controls'
        get 'systems'
        put 'systems'
      end
      member do
        get 'add_person'
        delete 'destroy_person'
        post 'create_person'
      end
    end
    resources :business_areas, :path => "/admin/business_areas"
    resources :sections, :path => "/admin/sections" do
      collection do
        get 'controls'
        put 'controls'
      end
    end
    resources :controls, :path => "/admin/controls" do
      collection do
        get 'sections'
        put 'sections'

        get 'systems'
        put 'systems'

        get 'biz_processes'
        put 'biz_processes'

        get 'controls'
        put 'controls'

        get 'evidence_descriptors'
        put 'evidence_descriptors'
      end
      member do
        get 'add_biz_process'
        delete 'destroy_biz_process'
        post 'create_biz_process'

        delete 'destroy_control'
        delete 'destroy_implemented_control'
        delete 'destroy_section'

        post 'implement'
      end
    end
    resources :documents, :path => "/admin/documents"
    resources :cycles, :path => "/admin/cycles" do
      member do
        get 'new_clone'
        put 'clone'
      end
    end
    resources :document_descriptors, :path => "/admin/document_descriptors"
    resources :programs, :path => "/admin/programs" do
      collection do
        get 'slug'
      end
    end
    resources :people, :path => "/admin/people"
    resources :systems, :path => "/admin/systems" do
      collection do
        get 'biz_processes'
        put 'biz_processes'
        get 'controls'
        put 'controls'
        get 'sections'
        put 'sections'
      end
      member do
        get 'add_person'
        delete 'destroy_person'
        post 'create_person'

        post 'clone'
      end
    end
  end

  resources :programs, :as => 'flow_programs', :only => [] do
    member do
      get 'show'
    end
  end

  resources :controls, :as => 'flow_controls'

  match 'programs_dash' => 'programs_dash#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # get "dev/index"

  if CmsRails::Application.sso_callback_url
    match 'sso/new' => 'sso#new', :as => 'login'
    match CmsRails::Application.sso_callback_url => "sso#callback"
    match 'sso/destroy' => 'sso#destroy', :as => 'logout'
  else
    match 'user_sessions/new' => 'user_sessions#new', :as => 'login'
    match 'user_sessions/destroy' => 'user_sessions#destroy', :as => 'logout'
    match 'user_sessions/create' => 'user_sessions#create'
  end

  # Document page
  match 'document/:action' => 'document'

  # Slugfilter widget routes
  match 'slugfilter/slug_update' => 'slugfilter#slug_update', :as => 'slugfilter_slug_update'
  match 'slugfilter/cycle_update' => 'slugfilter#cycle_update', :as => 'slugfilter_cycle_update'
  match 'slugfilter/program_update' => 'slugfilter#program_update', :as => 'slugfilter_program_update'
  match 'slugfilter/company_update' => 'slugfilter#company_update', :as => 'slugfilter_company_update'
  match 'slugfilter/values' => 'slugfilter#values', :as => 'slugfilter_values'

  match 'navigation/control_hierarchy' => 'navigation#control_hierarchy', :as => 'control_hierarchy'

  # Evidence workflow page
  match 'evidence/index' => 'evidence#index'
  match 'evidence/show_closed_control/:system_id/:control_id' => 'evidence#show_closed_control'
  match 'evidence/show_control/:system_id/:control_id' => 'evidence#show_control'
  match 'evidence/new/:system_id/:control_id/:descriptor_id' => 'evidence#new'
  match 'evidence/new_gdoc/:system_id/:control_id/:descriptor_id' => 'evidence#new_gdoc'
  match 'evidence/attach/:system_id/:control_id/:descriptor_id' => 'evidence#attach'
  match 'evidence/show/:document_id' => 'evidence#show'
  match 'evidence/update/:document_id' => 'evidence#update'
  match 'evidence/destroy/:system_id/:control_id/:document_id' => 'evidence#destroy'
  match 'evidence/review/:document_id/:value' => 'evidence#review'

  # Dashboard workflow page
  match 'dashboard/index' => 'dashboard#index'
  match 'dashboard/openbp/:id' => 'dashboard#openbp'
  match 'dashboard/closebp/:id' => 'dashboard#closebp'
  match 'dashboard/opensys/:biz_process_id/:id' => 'dashboard#opensys'
  match 'dashboard/closesys/:biz_process_id/:id' => 'dashboard#closesys'

  # Test report workflow page
  match 'testreport/:action' => 'testreport'

  # Testing workflow page
  match 'testing/index' => 'testing#index'
  match 'testing/show/:system_id/:control_id' => 'testing#show'
  match 'testing/show_closed/:system_id/:control_id' => 'testing#show_closed'
  match 'testing/update_control_state/:system_id/:control_id/:value' => 'testing#update_control_state'
  match 'testing/edit_control_text/:system_id/:control_id' => 'testing#edit_control_text'
  match 'testing/update_control_text/:system_id/:control_id' => 'testing#update_control_text'
  match 'testing/review/:document_id/:value' => 'testing#review'

  # Welcome page
  root :to => "welcome#index"
  # About page
  match 'about' => 'welcome#about', :as => 'about'
  match 'placeholder' => 'welcome#placeholder', :as => 'placeholder'
  match 'login_dispatch' => 'welcome#login_dispatch', :as => 'login_dispatch'

  # See how all your routes lay out with "rake routes"
end
