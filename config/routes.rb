Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'authenticate', to: 'authentication#authenticate'
  get '/categories/:name', to: 'categories#show'
  get 'customers/:customer_id/categories/:name', to: 'categories#show'
  get '/search', to: 'search#index'
  get '/promo', to: 'promo#index'
  resources :best_sellers, :sales_numbers, :groups, :product_mix, :categories
  resources :customers do
    resources :best_sellers, :sales_numbers, :products, :groups, :product_mix, :categories
  end
  resources :products do
    resources :sales_numbers
  end
end
