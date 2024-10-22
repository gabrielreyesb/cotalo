Rails.application.routes.draw do
  get 'pdf/generate'
  devise_for :users
  resources :materials
  resources :vendors
  resources :papers
  
  root 'pages#home'
  
  get 'pdf', to: 'pdf#index'
  get 'pdf/generate', to: 'pdf#generate' 

  resources :papers do
    get :new_form, on: :collection 
  end
end
