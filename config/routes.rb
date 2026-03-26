Rails.application.routes.draw do
  # Auth — outside namespace so Warden scope stays :user and authenticate_user! works
  devise_for :users, path: 'api/v1/auth',
    path_names: { sign_in: 'login', sign_out: 'logout', registration: 'register' },
    controllers: {
      sessions: 'api/v1/sessions',
      registrations: 'api/v1/registrations'
    }

  namespace :api do
    namespace :v1 do
      # Scans
      resources :scans, only: [:create, :show, :index]

      # Feedback
      resources :feedback, only: [:create]

      # Share (public, no auth)
      get 'share/:token', to: 'shares#show'
    end
  end

  # Health check
  get 'health', to: proc { [200, {}, ['ok']] }

  # Sidekiq Web (dev only)
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?
end
