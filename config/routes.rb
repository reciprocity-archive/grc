CmsRails::Application.routes.draw do

  resources :programs, :as => 'flow_programs', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'tooltip'
      get 'export_controls'
      get 'export'
      get 'sections'
      get 'controls'
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

  resources :cycles, :as => 'flow_cycles', :only => [:show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
    end
  end

  resources :sections, :as => 'flow_sections', :only => [:new, :edit, :create, :update, :destroy] do
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

  resources :locations, :as => 'flow_locations', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
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

  resources :risky_attributes, :as => 'flow_risky_attributes', :only => [:index, :show, :new, :edit, :create, :update, :destroy] do
    member do
      get 'delete'
      get 'tooltip'
      get 'delete'
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

  resources :object_people, :as => 'flow_object_people', :only => [:index, :create] do
    collection do
      get 'list_edit'
    end
  end

  resources :documents, :as => 'flow_documents' do
    member do
      get 'delete'
    end
  end

  resources :object_documents, :as => 'flow_object_documents', :only => [:index, :create] do
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

  match 'programs_dash' => 'programs_dash#index'
  match 'quick/programs' => 'quick#programs'
  match 'quick/sections' => 'quick#sections'
  match 'quick/controls' => 'quick#controls'
  match 'quick/biz_processes' => 'quick#biz_processes'
  match 'quick/accounts' => 'quick#accounts'
  match 'quick/people' => 'quick#people'
  match 'quick/categories' => 'quick#categories'
  match 'quick/options' => 'quick#options'
  match 'quick/systems' => 'quick#systems'
  match 'quick/products' => 'quick#products'

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
  get "mapping/buttons", :as => :mapping_buttons
  get "mapping/selected_section/:section_id" => 'mapping#selected_section', :as => :mapping_selected_section
  get "mapping/selected_control/:control_id" => 'mapping#selected_control', :as => :mapping_selected_control
  match 'mapping/sections/:program_id' => 'mapping#find_sections', :as => :mapping_sections
  match 'mapping/controls/:program_id/:control_type' => 'mapping#find_controls', :as => :mapping_controls

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
