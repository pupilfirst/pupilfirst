Rails.application.routes.draw do
  devise_for :users, only: %i[sessions omniauth_callbacks], controllers: { sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    post 'users/send_login_email', controller: 'users/sessions', action: 'send_login_email', as: 'user_send_login_email'
    get 'users/token', controller: 'users/sessions', action: 'token', as: 'user_token'

    if Rails.env.development?
      get 'users/auth/developer', controller: 'users/omniauth_callbacks', action: 'passthru', as: 'user_developer_omniauth_authorize'
      post 'users/auth/developer/callback', controller: 'users/omniauth_callbacks', action: 'developer'
    end
  end

  post 'users/email_bounce', controller: 'users/postmark_webhook', action: 'email_bounce'

  authenticate :user, ->(u) { u.admin_user&.superadmin? } do
    mount Delayed::Web::Engine, at: '/jobs'
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  ActiveAdmin.routes(self)

  # TODO: Remove these founder routes as we no longer have 'founders'. Always use the corresponding 'student' routes below.
  resource :founder, path: 'student', only: %i[edit update]

  resource :school, only: %i[show update]

  namespace :school, module: 'schools' do
    resources :faculty, only: %i[create destroy], as: 'coaches', path: 'coaches' do
      collection do
        get '/', action: 'school_index'
      end
    end

    resources :courses, only: %i[show update] do
      member do
        post 'close'
      end

      resource :curriculum, only: %i[show]
      resources :founders, as: 'students', path: 'students', only: %i[index create]
      resources :evaluation_criteria, only: %i[create]
      resources :levels, only: %i[create]

      resources :faculty, as: 'coaches', path: 'coaches', only: [] do
        collection do
          get '/', action: 'course_index'
        end

        member do
          post 'enroll'
          post 'leave'
        end
      end
    end

    resources :founders, as: 'students', path: 'students', except: %i[index] do
      collection do
        post 'team_up'
      end
    end

    resources :startups, as: 'teams', path: 'teams', only: %i[update] do
      member do
        post 'add_coach'
        post 'remove_coach'
      end
    end

    resources :evaluation_criteria, only: %i[update destroy]

    resources :levels, only: %i[update destroy] do
      resources :target_groups, only: %i[create]
    end

    resources :target_groups, only: %i[update destroy] do
      resources :targets, only: %i[create]
    end

    resources :targets, only: %i[update] do
      resource :quiz, only: %i[create]
    end

    resources :resources, only: %i[create]

    resource :quizzes, only: %i[update destroy]
  end

  resources :founders, only: %i[] do
    member do
      post 'select'
    end
  end

  scope 'student', controller: 'founders/dashboard', as: 'student' do
    get 'dashboard'
    get 'dashboard/targets/:id(/:slug)', action: 'target_overlay', as: 'dashboard_target'
  end

  resources :timeline_events, only: %i[create destroy] do
    member do
      post 'review'
      post 'undo_review'
      post 'send_feedback'
    end
  end

  scope 'founder/slack', as: 'founder_slack', controller: 'founders/slack_connect' do
    get 'connect'
    get 'callback'
    post 'disconnect'
  end

  resource :startup, only: [] do
    member do
      post 'level_up'
    end
  end

  resources :timeline_event_files, only: [] do
    member do
      get 'download'
    end
  end

  resources :faculty, only: %i[index show] do
    post 'connect', on: :member
    # get 'dashboard', to: 'faculty/dashboard#index'
    collection do
      get 'filter/:active_tab', to: 'faculty#index'
      get 'weekly_slots/:token', to: 'faculty#weekly_slots', as: 'weekly_slots'
      post 'save_weekly_slots/:token', to: 'faculty#save_weekly_slots', as: 'save_weekly_slots'
      delete 'weekly_slots/:token', to: 'faculty#mark_unavailable', as: 'mark_unavailable'
      get 'slots_saved/:token', to: 'faculty#slots_saved', as: 'slots_saved'
    end

    # scope module: 'faculty', controller: 'dashboard' do
    #   get '/', action: 'index'
    # end
  end

  # TODO: Remove these faculty routes as we no longer have 'faculty'. Always use the corresponding 'coaches' routes below.

  scope 'coaches', controller: 'faculty' do
    get '/', action: 'index', as: 'coaches_index'
    get '/:id', action: 'show', as: 'coach'
    get '/filter/:active_tab', action: 'index'
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
    get ':id/join_session(/:token)', action: 'join_session', as: 'join_session'
    patch ':id/feedback/comment/:token', action: 'comment_submit', as: 'comment_submit'
  end

  resources :prospective_applicants, only: %i[create]

  resources :colleges, only: :index

  resource :platform_feedback, only: %i[create]

  # Founder show
  scope 'students', controller: 'founders' do
    get '/:slug', action: 'show', as: 'student'
    get '/:slug/events/:page', action: 'paged_events', as: 'paged_events'
    get '/:slug/e/:event_id/:event_title', action: 'timeline_event_show', as: 'student_timeline_event_show'
  end

  # PupilFirst landing page
  get 'pupilfirst', to: 'home#pupilfirst'

  root 'home#index'

  get '/dashboard', to: redirect('/student/dashboard')

  scope 'policies', as: 'policies', controller: 'home' do
    get 'privacy'
    get 'terms'
  end

  resources :targets, only: [] do
    get 'select2_search', on: :collection

    member do
      get 'prerequisite_targets'
      get 'startup_feedback'
      get 'details'
      post 'auto_verify'
    end
  end

  # Public change log
  scope 'changelog', as: 'changelog', controller: 'changelog' do
    get 'archive'
    get '(/:year)', action: 'index'
  end

  resources :courses, only: [] do
    resource :coach_dashboard, controller: 'coach_dashboard', only: %i[show] do
      get 'timeline_events'
    end
  end

  resource :impersonation, only: %i[destroy]

  scope 'intercom', as: 'intercom', controller: 'intercom' do
    post 'user_create', action: 'user_create_webhook'
    post 'unsubscribe', action: 'email_unsubscribe_webhook'
  end

  match '/trello/bug_webhook', to: 'trello#bug_webhook', via: :all

  post '/heroku/deploy_webhook', to: 'heroku#deploy_webhook'

  # Handle incoming unsubscribe webhooks from SendInBlue
  post '/send_in_blue/unsubscribe', to: 'send_in_blue#unsubscribe_webhook'

  # Handle redirects of short URLs.
  get 'r/:unique_key', to: 'shortened_urls#redirect', as: 'short_redirect'

  get '/school_admin', to: 'school_admins#dashboard'

  get '/oauth/:provider', to: 'home#oauth', as: 'oauth', constraints: PupilFirstConstraint.new
  get '/oauth_error', to: 'home#oauth_error', as: 'oauth_error'

  # Allow developers to simulate the error pages.
  get '/errors/:error_type', to: 'errors#simulate', constraints: DevelopmentConstraint.new

  get '/favicon.ico', to: 'home#favicon'
end
