Rails.application.routes.draw do
  resources :general_configurations

  devise_for :users
  
  resources :toolings
  resources :manufacturing_processes
  resources :units
  resources :customers
  resources :materials
  resources :vendors
  resources :papers

  get 'quotes/calculate', to: 'quotes#calculate', as: :calculate_quotes 

  resources :quotes, only: [:new, :create, :show] do
    collection do
      post :search_customer
    end
    member do
      post :generate_pdf
    end
  end
  
  root 'pages#home'

  post 'send_quote/:id', to: 'pages#send_quote', as: :send_quote 
end
