Rails.application.routes.draw do
  root 'pages#home'
  get '/dashboard', to: 'pages#dashboard'
  devise_for :users
  resources :users, only: [] do
    resources :inventories, only: [:new, :create, :show, :edit, :update]
  end
  resources :organizations, only: [:new, :create, :show] do
    resources :inventories, only: [:new, :create, :show, :edit, :update]
  end
end
