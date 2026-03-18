Rails.application.routes.draw do
  root "pages#home"

  get "/events", to: "pages#events"
  get "/drinks", to: "pages#drinks"
  get "/products", to: "pages#drinks"
  get "/solutions", to: "pages#solutions"
  get "/cta-preview", to: "pages#cta_preview"
  get "/calculator", to: "pages#calculator"
  get "/contact", to: "pages#contact"
  get "/impressum", to: "pages#impressum"
  get "/datenschutz", to: "pages#datenschutz"
  get "/sitemap.xml", to: "pages#sitemap", defaults: { format: :xml }
  get "/monitoring/inquiry_flow", to: "monitoring#inquiry_flow"

  resources :inquiries, only: [ :create ]

  namespace :admin do
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    get "/password/reset", to: "passwords#new", as: :new_password
    post "/password/reset", to: "passwords#create", as: :password
    get "/password/edit", to: "passwords#edit", as: :edit_password
    patch "/password/edit", to: "passwords#update"

    root "dashboard#index"
    resources :categories, except: [ :show ]
    resources :events, except: [ :show ]
    resources :products, except: [ :show ] do
      post :bulk_update_prices, on: :collection
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
