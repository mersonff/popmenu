Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :imports, only: [ :create, :show ]

  resources :restaurants do
    resources :menus do
      resources :menu_items
    end
  end
end
