Rails.application.routes.draw do
  resources :quotes do
    collection do
      get :calculate
      post :search_customer
      post :generate_multi_pdf
    end
    member do
      get :pdf
      post :generate_pdf
    end
    resources :quote_processes
  end

  resources :general_configurations
  devise_for :users
  resources :extras do
    member do
      post :copy
    end
  end
  resources :units
  resources :materials do
    member do
      post :copy
    end
  end
  resources :unit_equivalences

  resources :manufacturing_processes do
    member do
      post :copy
    end
  end
  
  get '/home', to: 'pages#home', as: :home
  root 'pages#home'

  post 'send_quote/:id', to: 'pages#send_quote', as: :send_quote 

  resource :api_keys, only: [:edit, :update]
  resource :app_settings, only: [:edit, :update]
end
