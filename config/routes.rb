class Subdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain != 'www'
  end
end

class RootSubdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain == 'www'
  end
end

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  match '/mot-de-passe-oublie', to: 'passwords#new', via: [:get, :post]
  match '/nouveau-mot-de-passe', to: 'passwords#create', via: [:get, :post]

  constraints Subdomain do
    get '/', to: 'welcome#home'
    match '/login', to: 'auth#login', via: [:get, :post]
    match '/inscription', as: :signup, to: 'auth#signup', via: [:get, :post]
    match '/mon-compte', to: 'auth#edit_account', via: [:get, :patch]
    get '/logout', to: 'auth#logout'
    get '/mes-donnees', to: 'auth#gdpr_extract'

    get '/prestations/:slug', to: 'welcome#product'

    get '/mon_avis', to: 'reviews#new', as: :new_review
    post '/mon_avis', to: 'reviews#create'

    get '/reservations/:id', to: 'welcome#edit_reservation'
    delete '/reservations/:id', to: 'welcome#cancel_reservation'

    match '/parrainage', to: 'welcome#sponsorship', as: :sponsorship, via: [:get, :post]

    post '/cart/items', to: 'welcome#add_to_cart'
    match '/checkout', to: 'checkout#new', via: [:get, :post]
    post '/checkout/:reservation_id/times', to: 'welcome#checkout_times'
    get '/checkout/notification', to: 'checkout#callback'
    get '/checkout/save', to: 'checkout#save', as: :save_reservation
    resources :credits, only: [:index, :destroy]
    resources :ticket_purchases do
      collection do
        post :callback
      end
    end
    resources :ticket_distributions
    get '/paiements', to: 'welcome#payments'
    get '/distributions', to: 'welcome#distributions'

    get '/said', to: 'welcome#said'

    get '/invoice', to: 'welcome#invoice'
    match '/contact', to: 'welcome#contact', via: [:get, :post]

    scope module: :welcome do
      resources :reservations
      resources :subscriptions
    end

    get '/merci', to: 'welcome#thanks'
    get '/admin' => redirect('http://www.cryotera.xyz/admin')
  end

  constraints RootSubdomain do
    match '/admin', to: 'auth#admin', via: [:get, :post]
    match '/admin/inscription', to: 'auth#admin_signup', via: [:get, :patch]
    get '/logout', to: 'auth#logout'

    resources :franchises, only: [:index, :show, :create, :update]
    resources :reservations, only: [:index, :create, :update] do
      member do
        match :sign, via: [:get, :post]
      end
    end
    resources :payments, path: :paiements
    resources :users, path: :employes, only: [:index, :show, :create, :update, :destroy]
    resources :clients, only: [:index, :show, :create, :update, :destroy] do
      resources :comments, only: [:create, :update, :destroy]
      resources :credits, only: [] do
        collection do
          put :update, to: 'clients#update_credits'
        end
      end
    end
    resources :companies, path: :entreprises, only: [:index, :show, :create, :update] do
      resources :company_clients, only: [:create]
    end
    resources :rooms, path: :salles, only: [:index, :show, :create, :update, :destroy]
    resources :products, path: :prestations, only: [:index, :show, :create, :update, :destroy] do
      resources :images, only: [:destroy]
      resources :product_prices, only: [:create]
      resources :subscription_plans, only: [:create]
    end
    resources :coupons, path: 'codes-promo', only: [:index, :show, :create, :update, :destroy]
    resources :reviews, path: :avis, only: [:index, :update]
    resources :stats, only: [:index]
    resources :campaigns, only: [:index, :show, :create, :update, :destroy] do
      member do
        post :send_test
        post :send_now
      end
    end
    resources :blockers
    resources :business_hours
    resources :external_products
    resources :subscriptions
    resources :surveys do
      resources :survey_questions, only: [:create]
    end
    post '/templates/upsert', to: 'campaign_templates#upsert'
    post '/help', to: 'application#help'

    root 'application#root'
  end
end
