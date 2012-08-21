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

  resources :programs, :as => 'flow_programs', :only => [:show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'import'
      get 'sections'
      get 'controls'
      get 'section_controls'
      get 'control_sections'
      get 'category_controls'
    end
  end

  resources :cycles, :as => 'flow_cycles', :only => [:show, :create, :update]

  resources :sections, :as => 'flow_sections', :only => [:new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
    end
  end

  resources :controls, :as => 'flow_controls', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'sections'
      get 'implemented_controls'
      get 'implementing_controls'
    end
  end

  resources :systems, :as => 'flow_systems', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'subsystems_list'
      get 'subsystems_edit'
      post 'subsystems_update'
      get 'controls_list'
      get 'controls_edit'
      post 'controls_update'
    end
  end

  resources :transactions, :as => 'flow_transactions', :only => [:new, :edit, :create, :update, :destroy]

  resources :accounts, :as => 'flow_accounts'
  resources :people, :as => 'flow_people' do
    collection do
      get 'list'
      get 'list_edit'
      post 'list_update'
    end
  end

  resources :documents, :as => 'flow_documents' do
    collection do
      get 'list'
      get 'list_edit'
      post 'list_update'
    end
  end

  resources :categories, :as => 'flow_categories' do
    collection do
      get 'list'
      get 'list_edit'
      post 'list_update'
    end
  end

  match 'programs_dash' => 'programs_dash#index'
  match 'quick/programs' => 'quick#programs'
  match 'quick/sections' => 'quick#sections'
  match 'quick/controls' => 'quick#controls'
  match 'quick/biz_processes' => 'quick#biz_processes'
  match 'quick/accounts' => 'quick#accounts'
  match 'quick/people' => 'quick#people'
  match 'quick/systems' => 'quick#systems'

  match 'admin_dash' => 'admin_dash#index'

  get "mapping/show/:program_id" => 'mapping#show', :as => 'mapping_program'
  get 'mapping_section_dialog/:section_id' => 'mapping#section_dialog', :as => 'mapping_section_dialog'
  post "mapping/map_rcontrol"
  post "mapping/map_ccontrol"
  put "mapping/update/:section_id" => 'mapping#update', :as => 'mapping_update'
  get "mapping/buttons", :as => :mapping_buttons
  get "mapping/selected_section/:section_id" => 'mapping#selected_section', :as => :mapping_selected_section
  get "mapping/selected_control/:control_id" => 'mapping#selected_control', :as => :mapping_selected_control
  match 'mapping/sections/:program_id' => 'mapping#find_sections', :as => :mapping_sections
  match 'mapping/controls/:program_id/:control_type' => 'mapping#find_controls', :as => :mapping_controls
  post "mapping/create_rcontrol" => 'mapping#create_rcontrol', :as => 'mapping_create_rcontrol'
  post "mapping/create_ccontrol" => 'mapping#create_ccontrol', :as => 'mapping_create_ccontrol'

  match 'help/:slug' => 'help#show', :as => :help

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # get "dev/index"

  if CmsRails::Application.sso_callback_url
    match 'sso/new' => 'sso#new', :as => 'login'
    match CmsRails::Application.sso_callback_url => "sso#callback"
    match 'sso/destroy' => 'sso#destroy', :as => 'logout'
  else
    match 'login' => 'welcome#login', :as => 'login'
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
  get 'welcome/reload'

  # See how all your routes lay out with "rake routes"
end
