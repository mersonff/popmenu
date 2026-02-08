Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :restaurants do
    post :import, to: "imports#create"

    resources :menus do
      resources :menu_items
    end
  end
end
