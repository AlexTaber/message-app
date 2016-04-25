Rails.application.routes.draw do
  resources :users, only: [:new, :create, :edit, :update, :destroy] do
    member do
      get :user_owner_data
    end
  end
  resources :projects, only: [:new, :create, :edit, :update, :destroy] do
    member do
      get :add_users
      get :project_owner_data
    end
  end
  resources :conversations, only: [:new, :create, :show, :destroy]
  resources :messages, only: [:create, :destroy]
  resources :requests, only: [:new, :create, :update]
  resources :invites, only: [:new, :create]
  resources :user_projects, only: [:update, :destroy]
  resources :subscriptions, only: [:new, :create, :edit, :update, :destroy]
  resources :tiers, only: [:index]
  resources :password_recoveries, only: [:new, :create] do
    member do
      get :check
      post :verify
    end
  end
  resources :bans, only: [:new, :create, :update]
  resources :tasks, only: [:create, :update, :destroy] do
    member do
      put :transfer
    end
  end
  resources :claims, only: [:create, :destroy]

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  get '/mb-login' => 'sessions#mb_new'
  get '/splash' => 'sessions#splash'
  get '/home' => 'users#home'
  get '/message_box' => 'users#message_box'
  get '/mb-new-project' => 'users#mb_new_project'
  get '/typeahead' => 'users#typeahead'
  get '/owner-data' => 'users#owner_data'
  get '/users-data' => 'users#users_data'
  get '/projects-data' => 'projects#projects_data'
  get '/validate' => 'users#validate'
  get '/support' => 'static#support'
  get '/lazy_load' => 'conversations#lazy_load'
  post '/add_user' => 'conversations#add_user'
  get '/plugin-info' => 'users#plugin_info'
  get '/app-messages' => 'conversations#app_messages'
  post '/read-messages' => 'conversations#read_messages'
  get '/search' => 'conversations#search'
  get '/pricing' => 'tiers#pricing'
  post '/pusher-auth' => 'pusher#auth'

  root 'users#home'
end
