CmsRails::Application.routes.draw do
  match 'admin' => 'admin/base#index'

  scope :module => "admin" do
    resources :accounts, :path => "/admin/accounts"
    resources :biz_processes do
      collection do
        get 'controls'
        put 'controls'
        get 'systems'
        put 'systems'
      end
    end
    resources :biz_processes, :path => "/admin/biz_processes"
    resources :business_areas, :path => "/admin/business_areas"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # get "dev/index"

  resource :user_session

  if CmsRails::Application.sso_callback_url
    match 'sso/new' => 'sso#new', :as => 'login'
    match CmsRails::Application.sso_callback_url => "sso#callback"
    match 'sso/destroy' => 'sso#destroy', :as => 'logout'
  else
    match 'user_sessions/new' => 'user_sessions#new', :as => 'login'
    match 'user_sessions/destroy' => 'user_sessions#destroy', :as => 'logout'
    match 'user_sessions/create' => 'user_sessions#create'
  end

  match 'document/:action' => 'document'
  match 'slugfilter/:action' => 'slugfilter'

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

  match 'dashboard/index' => 'dashboard#index'

  match 'dashboard/openbp/:id' => 'dashboard#openbp'
  match 'dashboard/closebp/:id' => 'dashboard#closebp'
  match 'dashboard/opensys/:biz_process_id/:id' => 'dashboard#opensys'
  match 'dashboard/closesys/:biz_process_id/:id' => 'dashboard#closesys'

  match 'testreport/:action' => 'testreport'

  match 'testing/index' => 'testing#index'
  match 'testing/show/:system_id/:control_id' => 'testing#show'
  match 'testing/show_closed/:system_id/:control_id' => 'testing#show_closed'
  match 'testing/update_control_state/:system_id/:control_id/:value' => 'testing#update_control_state'
  match 'testing/edit_control_text/:system_id/:control_id' => 'testing#edit_control_text'
  match 'testing/update_control_text/:system_id/:control_id' => 'testing#update_control_text'
  match 'testing/review/:document_id/:value' => 'testing#review'

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
