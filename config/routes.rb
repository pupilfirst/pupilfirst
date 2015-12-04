Svapp::Application.routes.draw do
  devise_for(
    :users,
    controllers: {
      invitations: 'users/invitations',
      sessions: 'users/sessions'
    }
  )

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  match '/delayed_job' => DelayedJobWeb, anchor: false, via: [:get, :post]

  resources :users, only: [:show, :edit, :update] do
    member do
      get 'phone'
      post 'code'
      patch 'resend'
      post 'verify'
    end

    collection do
      patch 'update_password'
    end

    resource :startup, only: [:new, :edit, :update, :destroy] do
      post :add_founder
      patch :remove_founder
      patch :change_admin
      resources :timeline_events, only: [:create, :destroy, :update]
    end
  end

  resources :startups, only: [:index, :show] do
    collection do
      post 'team_leader_consent'
    end

    # resources :startup_jobs do
    #   patch :repost
    # # resources :founders do
    # # collection do
    # #   post :invite
    # # end
    # end
  end

  # get 'jobs', to: 'startup_jobs#list_all'

  resources :incubation, only: %w(show update) do
    collection do
      post 'cancel'
    end

    member do
      post 'add_cofounder'
    end
  end

  scope 'about', as: 'about', controller: 'about' do
    get '/', action: 'index'
    get 'transparency'
    get 'slack'
    get 'media-kit'
    get 'leaderboard'
    get 'contact'
    post 'contact', action: 'send_contact_email'
  end

  resources :faculty, only: %w(index) do
    post 'connect', on: :member
    collection do
      get 'weekly_slots/:token', to: 'faculty#weekly_slots', as: 'weekly_slots'
      post 'save_weekly_slots/:token', to: 'faculty#save_weekly_slots', as: 'save_weekly_slots'
    end
  end

  resources :resources, only: %w(index show) do
    member do
      get 'download'
    end
  end

  root 'home#index'
end
