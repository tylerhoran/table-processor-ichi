Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#index"

  # API routes
  namespace :api do
    namespace :v1 do
      post "tables/process", to: "tables#process_table"
    end
  end

  # Swagger documentation
  get "/swagger/v1/swagger.json", to: "swagger#index"

  # Swagger UI
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
end
