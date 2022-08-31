Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/api/v1/merchants/:id/items", to: "api/v1/merchant_items#index"

  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show]
    end
  end

  namespace :api do 
    namespace :v1 do
      resources :items, only: [:index]
    end
  end
end
