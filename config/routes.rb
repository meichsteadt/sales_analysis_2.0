Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'authenticate', to: 'authentication#authenticate'
  resources :best_sellers, :sales_numbers, :groups
  resources :customers do
    resources :best_sellers, :sales_numbers, :products, :groups
  end
  resources :products do
    resources :sales_numbers
  end
end
