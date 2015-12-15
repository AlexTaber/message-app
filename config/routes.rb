Rails.application.routes.draw do
  resources :users, only: [:new, :create, :destroy]

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  get '/home' => 'users#home'

  root 'sessions#new'
end
