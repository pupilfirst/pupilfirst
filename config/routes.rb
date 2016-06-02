Svapp::Application.routes.draw do
  get 'batch_application/index'

  get 'batch_application/apply'

  devise_for(
    :founders,
    controllers: {
      invitations: 'founders/invitations',
      sessions: 'founders/sessions'
    }
  )

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  match '/delayed_job' => DelayedJobWeb, anchor: false, via: [:get, :post]

  resource :founder, only: [:edit, :update] do
    member do
      get 'phone'
      patch 'set_unconfirmed_phone'
      get 'phone_verification'
      post 'code'
      patch 'resend'
      post 'verify'
    end

    collection do
      patch 'update_password'
    end

    resource :startup, only: [:new, :create, :edit, :update, :destroy] do
      post :add_founder
      patch :remove_founder
      patch :change_admin

      resources :timeline_events, only: [:create, :destroy, :update]
      resources :team_members, except: [:index]
    end
  end

  resources :startups, only: [:index, :show] do
    collection do
      post 'team_leader_consent'
    end

    resources :timeline_events, only: [] do
      resources :timeline_event_files, only: [] do
        member do
          get 'download'
        end
      end
    end
  end

  scope 'about', as: 'about', controller: 'about' do
    get '/', action: 'index'
    get 'slack'
    get 'media-kit'
    get 'leaderboard'
    get 'contact'
    post 'contact', action: 'send_contact_email'
  end

  resources :faculty, only: %w(index show) do
    post 'connect', on: :member
    collection do
      get 'filter/:active_tab', to: 'faculty#index'
      get 'weekly_slots/:token', to: 'faculty#weekly_slots', as: 'weekly_slots'
      post 'save_weekly_slots/:token', to: 'faculty#save_weekly_slots', as: 'save_weekly_slots'
      get 'mark_unavailable/:token', to: 'faculty#mark_unavailable', as: 'mark_unavailable'
      get 'slots_saved/:token', to: 'faculty#slots_saved', as: 'slots_saved'
    end
  end

  scope 'library', controller: 'resources' do
    get '/', action: 'index', as: 'resources'
    get '/:id', action: 'show', as: 'resource'
    get '/:id/download', action: 'download', as: 'download_resource'
  end

  get 'resources/:id', to: redirect('/library/%{id}')

  scope 'connect_request', controller: 'connect_request', as: 'connect_request' do
    get ':id/feedback/from_team/:token', action: 'feedback_from_team', as: 'feedback_from_team'
    get ':id/feedback/from_faculty/:token', action: 'feedback_from_faculty', as: 'feedback_from_faculty'
  end

  scope 'talent', as: 'talent', controller: 'talent' do
    get '/', action: 'index'
    post 'contact'
  end

  scope 'apply', as: 'apply', controller: 'batch_application' do
    get '/', action: 'index', as: 'index'
    get '/to/:batch', action: 'apply', as: 'batch'
    post '/to/:batch', action: 'submit', as: 'submit'
    get '/identify/:batch', action: 'identify', as: 'identify'
    post '/identify', action: 'send_sign_in_email', as: 'send_sign_in_email'
  end

  get 'founders/:slug', to: 'founders#founder_profile', as: 'founder_profile'

  get 'transparency', as: 'transparency', to: 'home#transparency'

  get 'timeline', as: 'timeline', to: 'timeline_events#timeline'

  root 'home#index'

  get 'changelog', to: 'home#changelog'

  get 'styleguide', to: 'home#styleguide'

  # custom defined 404 route to use with shortener gem's config
  get '/404', to: 'home#not_found'

  # used for shortened urls from the shortener gem
  get '/:id', to: 'shortener/shortened_urls#show'

  resource :platform_feedback
end
