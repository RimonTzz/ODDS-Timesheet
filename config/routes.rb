
Rails.application.routes.draw do
  resources :clients
  resources :projects do
    resources :users, controller: "project_users", only: [ :index, :new, :create, :destroy ]
  end
  resources :sites
  devise_for :users

  resources :timesheets do
    collection do
      get :export_pdf
    end
  end

  root "timesheets#index"

  get "/people_management", to: "people_management#index", as: "people_management"
  get "/project_management", to: "project_management#index", as: "project_management"
end

