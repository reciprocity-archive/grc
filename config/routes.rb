CmsRails::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  match 'dashboard/index' => 'dashboard#index'

  match 'dashboard/openbp/:id' => 'dashboard#openbp'
  match 'dashboard/closebp/:id' => 'dashboard#closebp'
  match 'dashboard/opensys/:biz_process_id/:id' => 'dashboard#opensys'
  match 'dashboard/closesys/:biz_process_id/:id' => 'dashboard#closesys'

  match 'testreport/index' => 'testreport#index'
  match 'testreport/top' => 'testreport#top'
  match 'testreport/regulation' => 'testreport#byregulation'
  match 'testreport/process' => 'testreport#byprocess'

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
