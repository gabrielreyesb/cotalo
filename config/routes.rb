Rails.application.routes.draw do
  resources :general_configurations

  get 'material_dimensions/show'
  get 'quotes/create'
  
  devise_for :users
  
  resources :toolings
  resources :manufacturing_processes
  resources :units
  resources :customers
  resources :materials
  resources :vendors
  resources :papers
  resources :quotes, only: [:index, :new, :create, :show]

  resources :quotes do
    collection do
      post :search_customer
      post :generate_pdf
    end
  end
  
  root 'pages#home'

  post 'send_quote/:id', to: 'pages#send_quote', as: :send_quote 
end
