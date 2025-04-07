Rails.application.routes.draw do
  namespace :admin do
    resources :people, only: [ :index, :edit, :update ] do
      member do
        post "assign_project"
        delete "unassign_project"
      end
    end
  end
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }, sign_out_via: [:delete, :get]
  resources :users, only: [ :edit ] do
    collection do
      get "profile/edit", to: "users#edit", as: "edit_user_profile"
    end
  end
  resources :clients, except: [:new] do
    resources :projects
  end
  resources :projects do
    resources :users, controller: "project_users", only: [ :index, :new, :create, :destroy, :edit, :update ]
    member do
      get "export_pdf"
    end
  end
  resources :sites


  resources :timesheets, only: [ :index, :new, :create ] do
    collection do
      get "export_pdf"
    end
  end
  resources :holidays

  get "users/check_email", to: "users#check_email"

  root "timesheets#index"

  get "/people_management", to: "people_management#index", as: "people_management"
  get "/project_management", to: "project_management#index", as: "project_management"
end
