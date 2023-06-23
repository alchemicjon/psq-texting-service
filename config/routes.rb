Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :messages, only: [:create, :update]
  post 'messages/delivery_callback', to: 'messages#update'
end
