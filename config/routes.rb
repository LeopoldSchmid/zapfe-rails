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
    resources :admin_users, except: [ :show, :destroy ]
    resource :system_settings, only: [ :edit, :update ]
    resources :suppliers, except: [ :show, :destroy ]
    resources :resources, except: [ :show, :destroy ]
    resources :checklist_templates, except: [ :show, :destroy ]
    resources :supplier_offerings, only: [ :new, :create, :edit, :update ]
    resources :inquiries, only: [ :index, :show ] do
      patch :assign, on: :member
      post :convert_to_order, on: :member
      post :add_attachments, on: :member
      post :add_note, on: :member
      patch :archive, on: :member
      get "attachments/:attachment_id", to: "inquiries#download_attachment", on: :member, as: :attachment
    end
    resources :orders, only: [ :index, :show, :new, :create, :update ] do
      resources :reservations, only: [ :create, :destroy ]
      resources :tasks, only: [ :create, :update, :destroy ]
      resources :procurement_plans, only: [ :create, :update ]
      resources :checklists, controller: "order_checklists", only: [ :create ] do
        resources :items, controller: "order_checklist_items", only: [ :update ]
      end
      resources :actual_time_entries, controller: "order_time_entries", only: [ :create, :destroy ]
      resources :offers, only: [ :create ]
      post :add_attachments, on: :member
      post :add_note, on: :member
      patch :archive, on: :member
      patch :unarchive, on: :member
      get "attachments/:attachment_id", to: "orders#download_attachment", on: :member, as: :attachment
    end
    resources :offers, only: [ :show, :update ] do
      post :finalize, on: :member
      post :duplicate, on: :member
      post :send_mail, on: :member
      patch :resolve, on: :member
      get :document, on: :member
      resources :line_items, controller: "offer_line_items", only: [ :create, :update, :destroy ]
      resources :time_entries, only: [ :create, :destroy ]
    end
    resources :categories, except: [ :show ]
    resources :events, except: [ :show ]
    resources :products, except: [ :show ] do
      post :bulk_update_prices, on: :collection
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
