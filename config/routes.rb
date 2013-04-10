CmsRails::Application.routes.draw do

  resources :programs, :as => 'flow_programs', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'delete'
      get 'sections'
      get 'controls'
    end
  end

  resources :directives, :as => 'flow_directives', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'export_controls'
      get 'export'
      get 'sections'
      get 'section_controls'
      get 'control_sections'
      get 'category_controls'
      get 'delete'
      get 'import_controls'
      post 'import_controls'
      get 'import'
      post 'import'
    end
  end

  resources :program_directives, :as => 'flow_program_directives', :only => [:index, :create, :destroy] do
    collection do
      get 'list_edit'
    end
  end

  resources :cycles, :as => 'flow_cycles', :only => [:show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'delete'
    end
  end

  resources :sections, :as => 'flow_sections', :only => [:index, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'delete'
    end
  end

  resources :controls, :as => 'flow_controls', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'sections'
      get 'implemented_controls'
      get 'implementing_controls'
      get 'systems'
      get 'risks'
      get 'delete'
    end
  end

  resources :systems, :as => 'flow_systems', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'delete'
    end
    collection do
      get 'import'
      post 'import'
      get 'export'
    end
  end

  resources :system_systems, :as => 'flow_system_systems', :only => [:index, :create] do
    collection do
      get 'list_edit'
    end
  end

  resources :system_controls, :as => 'flow_system_controls', :only => [:index, :create] do
    collection do
      get 'list_edit'
    end
  end

  resources :transactions, :as => 'flow_transactions', :only => [:new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
    end
  end

  resources :products, :as => 'flow_products', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
    end
  end

  resources :org_groups, :as => 'flow_org_groups', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
    end
  end

  resources :facilities, :as => 'flow_facilities', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
    end
  end

  resources :markets, :as => 'flow_markets', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
    end
  end

  resources :projects, :as => 'flow_projects', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
    end
  end

  resources :data_assets, :as => 'flow_data_assets', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
    end
  end

  resources :risky_attributes, :as => 'flow_risky_attributes', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
    end
  end

  resources :risks, :as => 'flow_risks', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
    end
    collection do
      get 'import'
      post 'import'
      get 'export'
    end
  end

  resources :control_risks, :as => 'flow_control_risks', :only => [:index, :create] do
    collection do
      get 'list_edit'
    end
  end

  resources :risk_risky_attributes, :as => 'flow_risk_risky_attributes', :only => [:index, :create] do
    collection do
      get 'list_edit'
    end
  end

  resources :accounts, :as => 'flow_accounts' do
    member do
      get 'delete'
    end
  end

  resources :people, :as => 'flow_people', :only => [:index, :show, :new, :create, :edit, :update, :destroy] do
    member do
      get 'delete'
    end
  end

  resources :object_people, :as => 'flow_object_people', :only => [:index, :create, :update, :destroy] do
    collection do
      get 'list_edit'
    end
  end

  resources :documents, :as => 'flow_documents' do
    member do
      get 'delete'
    end
  end

  resources :object_documents, :as => 'flow_object_documents', :only => [:index, :create, :destroy] do
    collection do
      get 'list_edit'
    end
  end

  resources :categories, :as => 'flow_categories' do
    member do
      get 'delete'
    end
    collection do
      get 'export'
    end
  end

  resources :options, :as => 'flow_options' do
    member do
      get 'delete'
    end
    collection do
      get 'export'
    end
  end

  resources :categorizations, :as => 'flow_categorizations', :only => [:index, :create] do
    collection do
      get 'list_edit'
    end
  end

  resources :relationships, :as => 'flow_relationships', :only => [:index, :create] do
    collection do
      get 'related_objects'
      get 'list_edit'
      get 'related'
      get 'graph'
    end
  end

  resources :pbc_lists, :as => 'flow_pbc_lists', :only => [:show, :new, :create, :edit, :update, :destroy] do
    member do
      get 'delete'
      get 'import'
      post 'import'
      get 'export'
      get 'export_responses'
    end
  end

  resources :requests, :as => 'flow_requests', :only => [:new, :create, :edit, :update, :destroy] do
    member do
      get 'delete'
    end
  end

  resources :responses, :as => 'flow_responses', :only => [:index, :create, :update, :destroy] do
    member do
      get 'delete'
    end
  end

  resources :population_samples, :as => 'flow_population_samples', :only => [:index, :create, :update, :destroy] do
    member do
      get 'delete'
    end
  end

  resources :meetings, :as => 'flow_meetings', :only => [:index, :new, :create, :edit, :update, :destroy] do
    member do
      get 'delete'
    end
  end

  resources :control_assessments, :as => 'flow_control_assessments', :only => [] do
    member do
      post 'rotate'
    end
  end

  match 'programs_dash' => 'programs_dash#index'
  match 'admin_dash' => 'admin_dash#index'

  # Catch-all for beta views
  get 'admin_dash/:action' => 'admin_dash'
  get 'design/templates/:name' => 'design#templates'
  get 'design/:action' => 'design'

  get "mapping/show/:program_id" => 'mapping#show', :as => 'mapping_program'
  get 'mapping_section_dialog/:section_id' => 'mapping#section_dialog', :as => 'mapping_section_dialog'
  post "mapping/map_rcontrol"
  post "mapping/map_ccontrol"
  put "mapping/update/:section_id" => 'mapping#update', :as => 'mapping_update'

  match 'help/:slug' => 'help#show', :as => :help
  post 'help' => 'help#edit', :as => :update_help

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # get "dev/index"

  if !Rails.env.test? && CmsRails::Application.sso_callback_url
    match 'sso/new' => 'sso#new', :as => 'login'
    match CmsRails::Application.sso_callback_url => "sso#callback"
    match 'sso/destroy' => 'sso#destroy', :as => 'logout'
  else
    match 'login' => 'user_sessions#login', :as => 'login'
    match 'user_sessions/destroy' => 'user_sessions#destroy', :as => 'logout'
    match 'user_sessions/create' => 'user_sessions#create'
  end

  # Document page
  match 'document/:action' => 'document'

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

  # Welcome page
  root :to => "welcome#index"
  # About page
  match 'about' => 'welcome#about', :as => 'about'
  match 'placeholder' => 'welcome#placeholder', :as => 'placeholder'
  match 'login_dispatch' => 'welcome#login_dispatch', :as => 'login_dispatch'
  get 'welcome/reload'

  # See how all your routes lay out with "rake routes"
end
