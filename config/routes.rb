Rails.application.routes.draw do
  root 'pages#home'
  get '/dashboard', to: 'pages#dashboard'
  devise_for :users, controllers: { registrations: 'registrations' }
  resources :users, only: [] do
    resources :inventories, only: [:new, :create, :show, :edit, :update]
  end
  resources :organizations, only: [:new, :create, :show] do
    resources :inventories, only: [:new, :create, :show, :edit, :update]
  end
  get '/inventory_users/:inventory_id/new', to: 'inventory_users#new', as: 'new_inventory_user'
  patch '/confirm_invitation', to: 'inventory_users#confirm_invitation', as: 'confirm_invitation'
  resources :inventory_users, only: [:create]
end
