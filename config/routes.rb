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

  resource :founder, only: %i[edit update] do
    member do
      get 'fee'
      post 'fee', action: 'fee_submit'

      scope module: 'founders', controller: 'dashboard' do
        get 'dashboard'
        post 'startup_restart'
        get 'dashboard/targets/:id(/:slug)', action: 'target_overlay'
      end
    end

    resource :startup, only: %i[edit update]
  end

  resources :team_members, except: %i[index show]
  resources :timeline_events, only: %i[create destroy]

  scope 'founder/facebook', as: 'founder_facebook', controller: 'founders/facebook_connect' do
    post 'connect'
    get 'connect_callback'
    post 'disconnect'
  end

  resource :startup, only: [] do
    member do
      post 'level_up'
    end
  end

  resources :startups, only: %i[index show] do
    member do
      get 'events/:page', action: 'paged_events', as: 'paged_events'
      get ':event_title/:event_id', action: 'timeline_event_show', as: 'timeline_event_show'
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

  resources :faculty, only: %i[index show] do
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

  get 'resources/:id', to: redirect('/library/%{id}') # rubocop:disable Style/FormatStringToken

  scope 'connect_request', controller: 'connect_request', as: 'connect_request' do
    get ':id/feedback/from_team/:token', action: 'feedback_from_team', as: 'feedback_from_team'
    get ':id/feedback/from_faculty/:token', action: 'feedback_from_faculty', as: 'feedback_from_faculty'
    get ':id/join_session(/:token)', action: 'join_session', as: 'join_session'
  end

  scope 'talent', as: 'talent', controller: 'talent' do
    get '/', action: 'index'
    post 'contact'
  end

  get 'apply', to: redirect('/join')
  get 'join', to: 'admissions#join'
  post 'join', to: 'admissions#register'

  scope 'admissions', as: 'admissions', controller: 'admissions' do
    get 'screening'
    post 'screening', action: 'screening_submit'
    get 'fee'
    post 'fee', action: 'fee_submit'
    post 'coupon_submit'
    patch 'coupon_remove'
    get 'founders'
    post 'founders', action: 'founders_submit'
    post 'team_lead'
    get 'accept_invitation'
    patch 'update_founder'
  end

  resources :prospective_applicants, only: %i[create]

  # webhook url for intercom user create - used to strip them off user_id
  post 'intercom_user_create', controller: 'intercom', action: 'user_create'

  resources :colleges, only: :index

  resource :platform_feedback, only: %i[create]

  # Redirect + webhook from Instamojo
  scope 'instamojo', as: 'instamojo', controller: 'instamojo' do
    get 'redirect'
    post 'webhook'
  end

  # Custom founder profile page.
  get 'founders/:slug', to: 'founders#founder_profile', as: 'founder_profile'

  # Story of startup village, accessed via about pages.
  get 'story', as: 'story', to: 'home#story'

  # Previous transparency page re-directed to story
  get 'transparency', to: redirect('/story')

  # Application process tour of SV.CO
  get 'tour', to: 'home#tour'

  root 'home#index'

  # /slack redirected to /about/slack
  get '/slack', to: redirect('/about/slack')

  # Also have /StartInCollege
  get 'StartInCollege', to: redirect('/startincollege')

  # redirect /startincollege to /sixways
  get 'startincollege', to: redirect('/sixways')

  scope 'policies', as: 'policies', controller: 'home' do
    get 'privacy'
    get 'terms'
  end

  scope 'sixways', as: 'six_ways', controller: 'six_ways' do
    get '/', action: 'index'
    get 'gtu', action: 'gtu_index'
    get 'start'
    get 'student_details'
    post 'create_student'
    # TODO: why is a patch request send after a few rounds of errors ?
    post 'save_student_details'
    patch 'save_student_details'
    get 'quiz/:module_name', action: 'quiz', as: 'quiz'
    get ':module_name/:chapter_name', action: 'module', as: 'module'
    post 'quiz_submission'
    get 'course_end'
    get 'completion_certificate'
  end

  resources :targets, only: [] do
    get 'select2_search', on: :collection
    member do
      get 'download_rubric'
      get 'prerequisite_targets'
      get 'founder_statuses'
      get 'startup_feedback'
      get 'details'
    end
  end

  scope 'paytm', as: 'paytm', controller: 'paytm' do
    get 'pay'
    post 'callback'
  end

  # Public change log
  scope 'changelog', as: 'changelog', controller: 'changelog' do
    get '/', action: 'index'
    get 'archive'
  end

  resource :impersonation, only: %i[destroy]

  # TODO: Remove this route once PayTM is correctly configured with '/paytm/callback' as the redirect_url.
  post '/', to: 'home#paytm_callback'

  match '/trello/bug_webhook', to: 'trello#bug_webhook', via: :all

  post '/heroku/deploy_webhook', to: 'heroku#deploy_webhook'

  # Handle redirects of short URLs.
  get 'r/:unique_key', to: 'shortened_urls#redirect', as: 'short_redirect'

  # Handle shortener-gem form URLs for a while (backward compatibility).
  get '/:unique_key', to: 'shortened_urls#redirect', constraints: { unique_key: /[0-9a-z]{5}/ }
end
