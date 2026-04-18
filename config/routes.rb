Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :books, only: [ :index, :show, :create, :update, :destroy ]
      resources :orders, only: [ :index, :show, :create, :destroy ]
      resources :inventory, only: [ :show, :create ], param: :book_id
      resources :prices, only: [ :show, :create ], param: :book_id
      resources :events, only: [ :index ]
    end
  end

  namespace :catalog do
    resources :books, only: [ :index, :show, :new, :create ]
  end

  namespace :inventory do
    resources :stock_items, only: [ :show, :new, :create ]
  end
end
