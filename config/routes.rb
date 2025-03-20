
Rails.application.routes.draw do
  namespace :admin do
    resources :people, only: [:index, :edit, :update] do
      member do
        post "assign_project"
        delete "unassign_project"
      end
    end
  end
  devise_for :users do
    get "profile/edit", to: "devise/registrations#edit", as: :edit_user_profile
    patch "profile", to: "devise/registrations#update", as: :user_profile
    put "profile", to: "devise/registrations#update", as: :update_user_profile
  end
  resources :users, only: [:edit] do
    collection do
      get "profile/edit", to: "users#edit", as: "edit_user_profile"
    end
  end
  resources :clients
  resources :projects do
    resources :users, controller: "project_users", only: [ :index, :new, :create, :destroy, :edit, :update ]
  end
  resources :sites


  resources :timesheets do
    collection do
      get :export_pdf
    end
  end

  root "timesheets#index"

  get "/people_management", to: "people_management#index", as: "people_management"
  get "/project_management", to: "project_management#index", as: "project_management"
end

