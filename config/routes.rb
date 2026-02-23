Rails.application.routes.draw do
  root "pages#home"

  get "/events", to: "pages#events"
  get "/drinks", to: "pages#drinks"
  get "/products", to: "pages#drinks"
  get "/calculator", to: "pages#calculator"
  get "/contact", to: "pages#contact"
  get "/impressum", to: "pages#impressum"
  get "/datenschutz", to: "pages#datenschutz"

  resources :inquiries, only: [ :create ]

  namespace :admin do
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    root "dashboard#index"
    resources :categories, except: [ :show ]
    resources :events, except: [ :show ]
    resources :products, except: [ :show ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
