require 'override_csp'

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end

  direct :rails_public_blob do |blob|
    if Rails.env.development? || Rails.env.test? || ENV['CLOUDFRONT_HOST'].blank?
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
    get 'users/reset_password', controller: 'users/sessions', action: 'reset_password', as: 'reset_password'
    post 'users/update_password', controller: 'users/sessions', action: 'update_password', as: 'update_password'
    get 'users/sign_in_with_email', controller: 'users/sessions', action: 'sign_in_with_email', as: 'sign_in_with_email'
    get 'users/request_password_reset', controller: 'users/sessions', action: 'request_password_reset', as: 'request_password_reset'

    if Rails.env.development?
      get 'users/auth/developer', controller: 'users/omniauth_callbacks', action: 'passthru', as: 'user_developer_omniauth_authorize'
      post 'users/auth/developer/callback', controller: 'users/omniauth_callbacks', action: 'developer'
    end
  end

  get 'users/delete_account', controller: 'users', action: 'delete_account', as: 'delete_account'

  post 'users/email_bounce', controller: 'users/postmark_webhook', action: 'email_bounce'

  authenticate :user, ->(u) { AdminUser.where(email: u.email).present? } do
    mount Delayed::Web::Engine, at: '/jobs'
    mount OverrideCsp.new(Flipper::UI.app(Flipper)), at: '/toggle'
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  resource :applicants, only: [] do
    get '/:token/enroll', action: 'enroll', as: 'enroll'
  end

  resources :notifications, only: %i[show]

  resource :school, only: %i[show update] do
    get 'customize'
    get 'admins'
    post 'images'
  end

  namespace :school, module: 'schools' do
    resources :faculty, only: %i[create update destroy], as: 'coaches', path: 'coaches' do
      collection do
        get '/', action: 'school_index'
      end
    end

    resources :targets, only: [] do
      resource :content_block, only: %i[create]
    end

    resources :courses, only: %i[index show new] do
      member do
        get 'applicants'
        get 'details'
        get 'images', action: :details
        get 'actions', action: :details
        get 'curriculum'
        get 'exports'
        get 'authors'
        get 'certificates'
        post 'certificates', action: 'create_certificate'
        post 'bulk_import_students'
        get 'evaluation_criteria'
        post 'attach_images'
      end

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

      post 'mark_teams_active'
      get 'students'
      get 'inactive_students'
      post 'delete_coach_enrollment'
      post 'update_coach_enrollments'
    end

    resources :founders, as: 'students', path: 'students', except: %i[index] do
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
  end

  resources :timeline_event_files, only: %i[create] do
    member do
      get 'download'
    end
  end

  scope 'coaches', controller: 'faculty' do
    get '/', action: 'index', as: 'coaches_index'
    get '/:id(/:slug)', action: 'show', as: 'coach'
    get '/filter/:active_tab', action: 'index'
  end

  # Founder show
  scope 'students', controller: 'founders' do
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
      get 'students', action: 'students'
      get 'leaderboard', action: 'leaderboard'
      get 'curriculum', action: 'curriculum'
      get 'report', action: 'report'
      get 'apply', action: 'apply'
      post 'apply', action: 'process_application'
      get '/(:name)', action: 'show'
    end
  end

  resources :markdown_attachments, only: %i[create] do
    member do
      get '/:token', action: 'download', as: 'download'
    end
  end

  get '/c/:serial_number', to: 'issued_certificates#verify', as: :issued_certificate
  get '/help/:document', to: 'help#show'
  get '/oauth/:provider', to: 'home#oauth', as: 'oauth', constraints: SsoConstraint.new
  get '/oauth_error', to: 'home#oauth_error', as: 'oauth_error'

  # Allow developers to simulate the error pages.
  get '/errors/:error_type', to: 'errors#simulate', constraints: DevelopmentConstraint.new

  get '/service-worker.js', to: 'home#service_worker'
  get '/favicon.ico', to: 'home#favicon'
end
