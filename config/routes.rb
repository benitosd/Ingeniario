Rails.application.routes.draw do
  resources :output_reports do
    member do
      post :approve  # Para aprobar el informe
    end
  end
  resources :stocks do
    member do
      get 'download_qr'
      post :assign_to_user
      post :return_from_user
      post :move_to_section
    end
    collection do
      get 'find_by_reference'
    end
  end
  resources :item_locations
  resources :sections
 
  resources :groups
  resources :families do
    patch :update_inline, on: :member
  end

  # Nuevas rutas
  resources :warehouses do
    member do
      get :sections
    end
    resources :sections
  end

  resources :items do
    resources :item_locations do
      get 'history', on: :collection
    end
    member do
      post 'assign_to_user'
      post 'move_to_section'
    end
  end

 
  devise_for :users
  resources :users
   
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
   # Ruta para el dashboard
  get 'dashboard', to: 'dashboard#index'
  get 'inventory_report', to: 'dashboard#inventory_report'
  # Defines the root path route ("/")
  root "home#index"
  get "search/query"
end
