Rails.application.routes.draw do

  # Home
  root 'home#index'

  # Admin
  get '/admin' => 'admin#index'
  get '/lecturer' => 'admin#index'

  # Administration.
  namespace :admin do

    # Managing students/lecturers and admins.
    resources :users

    # Managing units and their leaders.
    resources :units do
      post '/leaders' => 'units#create_leader'
      delete '/leader/:id' => 'units#delete_leader', as: 'delete_leader'

      get '/lectures' => 'units#lectures', as: 'lectures'
      get '/report' => 'units#report', as: 'report'
    end

    # Some additions ot the students/lecturers and admins.
    get '/users/new/type/:type/' => 'users#new', :as => :new_user_with_type
    get '/users/type/:type/' => 'users#index', :as => :users_with_type

    # Managing lectures, their units and their students.
    resources :lectures do
      get '/register' => 'lectures#register', as: 'register'
      post '/register' => 'lectures#register_student'
      post '/add' => 'lectures#add_student', as: 'add_student'
      post '/copy' => 'lectures#copy_students', as: 'copy_students'
      delete '/student/:id' => 'lectures#remove_student', as: 'remove_student'
    end

    get '/lectures_on' => 'lectures#on_day', as: 'lectures_on'

    # Logs of who has been doing what in the system.
    get '/logs' => 'logs#index'
  end

  # Pages.
  get '/home' => 'home#index'
  get '/about' => 'home#about'

  # User authentication system.
  devise_for :users, :controllers => {
    :sessions => 'users/sessions'
  }
end
