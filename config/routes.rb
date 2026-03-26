Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      # Auth
      devise_for :users, path: 'auth',
        path_names: { sign_in: 'login', sign_out: 'logout', registration: 'register' },
        controllers: {
          sessions: 'api/v1/sessions',
          registrations: 'api/v1/registrations'
        }

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
