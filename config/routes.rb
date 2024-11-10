Rails.application.routes.draw do
  resources :general_configurations
  get 'material_dimensions/show'
  get 'quotes/new'
  get 'quotes/create'
  resources :toolings
  resources :manufacturing_processes
  resources :units
  resources :customers
  devise_for :users
  resources :materials
  resources :vendors
  resources :papers
  resources :quotes, only: [:new, :create]
  
  root 'pages#home'

  get 'pdf/generate', to: 'pdf#generate' 
  post 'send_quote/:id', to: 'pages#send_quote', as: :send_quote 

  resources :papers do
    get :new_form, on: :collection 
  end
  
  resources :quotes do
    member do
      get 'calculate_quote'
    end
  end
  
end
