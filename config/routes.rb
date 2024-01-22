Rails.application.routes.draw do
  get 'pages/index'
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#index"
  get "product", to: "pages#product"
  post "parse_site", to: "pages#parse_site"
end
