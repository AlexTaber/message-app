Rails.application.routes.draw do
  resources :users, only: [:new, :create, :destroy]
  resources :sites, only: [:new, :create, :destroy]
  resources :conversations, only: [:new, :create, :destroy]
  resources :messages, only: [:create]

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  get '/home' => 'users#home'

  root 'sessions#new'
end
