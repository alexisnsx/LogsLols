Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :tasks do
    resources :reminders, only: [ :create]
    member do
      patch :completion
      get 'original'
    end
  end
  resources :chats, only: [ :index, :show, :create, :delete ] do
    resources :conversations, only: [ :index, :new, :create, :show ]
  end
  resources :conversation_responses, only: [ :index ]

  # if we would like for the url to be custom /logslols/username
  # get '*username', to: 'pages#home'
  get "get_tasks_due", to: "tasks#get_tasks_due"
  get "search", to: "tasks#search"
end
