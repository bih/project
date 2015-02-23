Rails.application.routes.draw do

  # Home
  root 'home#index'

  # Admin
  get '/admin' => 'admin#index'
  get '/lecturer' => 'admin#index'

  namespace :admin do
    resources :users
    resources :units do
      post '/leaders' => 'units#create_leader'
      delete '/leader/:id' => 'units#delete_leader', as: 'delete_leader'

      get '/lectures' => 'units#lectures', as: 'lectures'
    end

    get '/users/new/type/:type/' => 'users#new', :as => :new_user_with_type
    get '/users/type/:type/' => 'users#index', :as => :users_with_type

    resources :lectures do
      get '/register' => 'lectures#register', as: 'register'
      post '/register' => 'lectures#register_student'
      post '/add' => 'lectures#add_student', as: 'add_student'
      post '/copy' => 'lectures#copy_students', as: 'copy_students'
      delete '/student/:id' => 'lectures#remove_student', as: 'remove_student'
    end

    get '/logs' => 'logs#index'
  end

  # Pages.
  get '/home' => 'home#index'
  get '/about' => 'home#about'

  # User authentication system.
  devise_for :users, :controllers => {
    :sessions => 'users/sessions'
  }

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
