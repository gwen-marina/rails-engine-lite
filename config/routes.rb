Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/api/v1/merchants/:id/items', to: 'api/v1/merchant_items#index'
  get '/api/v1/items/find_all', to: 'api/v1/items#find_all'
  get '/api/v1/items/:id', to: 'api/v1/items#show'
  get '/api/v1/items/:id/merchant', to: 'api/v1/merchant_items#show'
  get '/api/v1/merchants/find', to: 'api/v1/merchants#find'
 
  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show]
    end
  end

  namespace :api do 
    namespace :v1 do
      resources :items, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
