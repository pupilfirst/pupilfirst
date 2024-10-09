require 'override_csp'

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  direct :rails_public_blob do |blob|
    if Rails.env.local? || ENV['CLOUDFRONT_HOST'].blank?
      route =
        if blob.is_a?(ActiveStorage::Variant) || blob.is_a?(ActiveStorage::VariantWithRecord)
          :rails_representation
        else
          :rails_blob
        end
      route_for(route, blob, only_path: true)
    else
      Cloudfront::GenerateSignedUrlService.new(blob).generate_url
    end
  end

  post '/graphql', to: 'graphql#execute'

  devise_for :users, only: %i[sessions omniauth_callbacks], controllers: { sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    post 'users/send_reset_password_email', controller: 'users/sessions', action: 'send_reset_password_email', as: 'user_send_reset_password_email'
    get 'users/token', controller: 'users/sessions', action: 'token', as: 'user_token'
    get 'users/auth_callback', controller: 'users/sessions', action: 'auth_callback', as: 'user_auth_callback'
    get 'users/reset_password', controller: 'users/sessions', action: 'reset_password', as: 'reset_password'
    post 'users/update_password', controller: 'users/sessions', action: 'update_password', as: 'update_password'
    get 'users/sign_in_with_password', controller: 'users/sessions', action: 'sign_in_with_password', as: 'sign_in_with_password'
    post 'users/sign_in_with_otp', controller: 'users/sessions', action: 'sign_in_with_otp', as: 'sign_in_with_otp'
    get 'users/request_password_reset', controller: 'users/sessions', action: 'request_password_reset', as: 'request_password_reset'
    get 'users/email_sent', controller: 'users/sessions', action: 'email_sent', as: 'session_email_sent'

    if Rails.env.development?
      get 'users/auth/developer', controller: 'users/omniauth_callbacks', action: 'passthru', as: 'user_developer_omniauth_authorize'
      match 'users/auth/developer/callback', controller: 'users/omniauth_callbacks', action: 'developer', via: [:get, :post]
    end
  end

  get 'users/delete_account', controller: 'users', action: 'delete_account', as: 'delete_account'

  post 'users/email_bounce', controller: 'users/postmark_webhook', action: 'email_bounce'

  get 'users/update_email', controller: 'users', action: 'update_email', as: 'update_email'

  authenticate :user, ->(u) { AdminUser.where(email: u.email).present? } do
    mount Delayed::Web::Engine, at: '/jobs'
    mount OverrideCsp.new(Flipper::UI.app(Flipper)), at: '/toggle'
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  resource :applicants, only: [] do
    get '/:token/enroll', action: 'enroll', as: 'enroll'
  end

  resources :notifications, only: %i[show]

  resource :school, only: [] do
    get 'customize'
    get 'admins'
    get 'standing'
    get 'discord_configuration'
    get 'discord_server_roles'
    get 'code_of_conduct'
    patch 'code_of_conduct', action: 'update_code_of_conduct'
    patch 'toggle_standing'
    patch 'discord_credentials'
    post 'images'
    post 'discord_sync_roles'
    post 'update_default_discord_roles'

    resources :standings, controller: 'schools/standings', except: [:index, :show]
  end

  namespace :school, module: 'schools' do
    [
      '/',
      'courses',
      'courses/new',
      'courses/:course_id',
      'courses/:course_id/details',
      'courses/:course_id/images',
      'courses/:course_id/actions',
      'courses/:course_id/cohorts',
      'courses/:course_id/cohorts/new',
      'cohorts/:cohort_id/details',
      'cohorts/:cohort_id/actions',
      'courses/:course_id/students',
      'courses/:course_id/students/new',
      'courses/:course_id/students/import',
      'students/:student_id/details',
      'students/:student_id/actions',
      'students/:student_id/standing',
      'courses/:course_id/teams',
      'courses/:course_id/teams/new',
      'teams/:team_id/details',
      'teams/:team_id/actions',
    ].each do |path|
      get path, action: 'school_router'
    end

    resources :users, only: %i[index show edit update]

    resources :faculty, only: %i[create update destroy], as: 'coaches', path: 'coaches' do
      collection do
        get '/', action: 'school_index'
      end
    end

    resources :calendars, only: %i[update], controller: 'calendars'
    resources :calendar_events, only: %i[update destroy], controller: 'calendar_events'

    resources :targets, only: [] do
      resource :content_block, only: %i[create]
      member do
        get 'action', action: 'action'
        patch 'update_action', action: 'update_action'
      end
    end

    resources :cohorts, only: [] do
      member do
        post 'bulk_import_students'
      end
    end

    resources :assignments, only: [] do
      member do
        patch :update_milestone_number
      end
    end

    resources :courses, only: [] do
      member do
        get 'applicants'
        get 'calendar_events'
        get 'curriculum'
        get 'exports'
        get 'authors'
        get 'certificates'
        post 'certificates', action: 'create_certificate'
        get 'evaluation_criteria'
        post 'attach_images'
        get 'calendar_month_data'
        get 'assignments'
      end

      resources :calendar_events, only: %i[new create show edit], controller: 'calendar_events'

      resources :calendars, only: %i[new create edit], controller: 'calendars'

      resources :authors, only: %w[show new]

      resources :applicants, only: :show do
        member do
          get 'actions', action: :show
          get 'details', action: :show
        end
      end

      resources :targets, only: [] do
        member do
          get 'content'
          get 'details'
          get 'versions'
        end
      end

      resources :levels, only: %i[create]

      resources :faculty, as: 'coaches', path: 'coaches', only: [] do
        collection do
          get '/', action: 'course_index'
        end
      end

      get 'students'
      post 'delete_coach_enrollment'
      post 'update_coach_enrollments'
    end

    resources :students, as: 'students', path: 'students', except: %i[index] do
      collection do
        post 'team_up'
      end
    end

    resources :levels, only: %i[update] do
      resources :target_groups, only: %i[create]
    end

    resources :target_groups, only: %i[update]

    resources :communities, only: %i[index]
  end

  resources :organisations, only: %i[show index] do
    resources :cohorts, module: 'organisations', only: %i[show] do
      member do
        get 'students'
      end
    end

    resources :courses,  module: 'organisations', only: [] do
      member do
        get 'active_cohorts'
        get 'ended_cohorts'
      end
    end
  end

  namespace :org, module: 'organisations' do
    resources :students, only: %[show] do
      member do
        get 'submissions'
        get 'standing'
      end
    end
  end

  resources :communities, only: %i[show] do
    member do
      get 'new_topic'
      get ':name', action: 'show'
    end
  end

  get 'topics/:id(/:title)', controller: 'topics', action: 'show', as: 'topic'

  get 'posts/:id/versions', controller: 'posts', action: 'versions', as: 'post_version'

  get 'dashboard', controller: 'users', action: 'dashboard', as: 'dashboard'

  resource :user, only: %i[edit] do
    post 'upload_avatar'
    post 'clear_discord_id'
    get 'discord_account_required'
    get 'standing'
  end

  resources :timeline_event_files, only: %i[create] do
    member do
      get 'download'
    end
  end

  scope 'coaches', controller: 'faculty' do
    get '/', action: 'index', as: 'coaches_index'
  end

  # Student show
  scope 'students', controller: 'students' do
    get '/:id/report', action: 'report', as: 'student_report'
  end

  get 'styleguide', to: 'home#styleguide', constraints: DevelopmentConstraint.new

  get 'manifest', to: 'home#manifest'
  get 'offline', to: 'home#offline'
  root 'home#index'

  get 'agreements/:agreement_type', as: 'agreement', controller: 'home', action: 'agreement'

  resources :targets, only: %i[show] do
    member do
      get 'details_v2'
      get ':slug', action: 'show'
      post 'mark_as_read'
    end
  end

  resources :timeline_events, only: %i[show], path: 'submissions' do
    member do
      get 'review', action: 'review'
    end
  end

  resources :courses, only: %i[show] do
    member do
      get 'review', action: 'review'
      get 'cohorts', action: 'cohorts'
      get 'calendar', action: 'calendar'
      get 'calendar_month_data', action: 'calendar_month_data'
      get 'leaderboard', action: 'leaderboard'
      get 'curriculum', action: 'curriculum'
      get 'report', action: 'report'
      get 'apply', action: 'apply'
      post 'apply', action: 'process_application'
      get '/(:name)', action: 'show'
    end
  end

  resources :cohorts, only: %i[show] do
    member do
      get 'students', action: 'students'
    end
  end

  resources :markdown_attachments, only: %i[create] do
    member do
      get '/:token', action: 'download', as: 'download'
    end
  end

  get '/c/:serial_number', to: 'issued_certificates#verify', as: :issued_certificate
  get '/help/:document', to: 'help#show'
  get '/oauth/:provider', to: 'home#oauth', as: 'oauth', constraints: DomainConstraint.new(:sso)
  get '/oauth_error', to: 'home#oauth_error', as: 'oauth_error'

  namespace :inbound_webhooks do
    resources :beckn, only: [:create], constraints: DomainConstraint.new(:beckn)
  end

  # Allow developers to simulate the error pages.
  get '/errors/:error_type', to: 'errors#simulate', constraints: DevelopmentConstraint.new

  get '/service-worker.js', to: 'home#service_worker'
  get '/favicon.ico', to: 'home#favicon'
end
