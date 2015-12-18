Rails.application.routes.draw do
  resources :users, only: [:new, :create, :edit, :update, :destroy]
  resources :sites, only: [:new, :create, :edit, :update, :destroy] do
    member do
      get :add_users
    end
  end
  resources :conversations, only: [:new, :create, :destroy]
  resources :messages, only: [:create]

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  get '/home' => 'users#home'
  get '/message_box' => 'users#message_box'

  root 'sessions#new'
end
