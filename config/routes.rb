require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Defines the root path route ("/")
  authenticate :user do
    root to: "documents#index", as: :authenticated_root
  end
  unauthenticated do
    root to: "home#index", as: :unauthenticated_root
  end

  resources :documents, only: [:index, :new, :create, :show]
end
