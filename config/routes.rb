Rails.application.routes.draw do
  resources :users, only: [:new, :create, :edit, :update, :destroy]
  resources :sites, only: [:new, :create, :edit, :update, :destroy] do
    member do
      get :add_users
    end
  end
  resources :conversations, only: [:new, :create, :destroy]
  resources :messages, only: [:create]
  resources :requests, only: [:new, :create, :update]
  resources :invites, only: [:new, :create]
  resources :user_sites, only: [:update, :destroy]
  resources :subscriptions, only: [:new, :create, :edit, :update, :destroy]
  resources :password_recoveries, only: [:new, :create] do
    member do
      get :check
      post :verify
    end
  end
  resources :bans, only: [:create]

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  get '/mb-login' => 'sessions#mb_new'
  get '/splash' => 'sessions#splash'
  get '/home' => 'users#home'
  get '/message_box' => 'users#message_box'
  get '/token_redirect' => 'users#token_redirect'
  get '/typeahead' => 'users#typeahead'
  post '/add_user' => 'conversations#add_user'

  root 'users#home'
end
