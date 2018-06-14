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
  resource :founder, only: %i[edit update] do
    member do
      get 'fee'
      post 'fee', action: 'fee_submit'

      scope module: 'founders', controller: 'dashboard' do
        get 'dashboard'
        get 'dashboard/targets/:id(/:slug)', action: 'target_overlay', as: 'dashboard_target'
      end
    end
  end

  scope 'student', controller: 'founders/dashboard', as: 'student' do
    get 'dashboard'
    get 'dashboard/targets/:id(/:slug)', action: 'target_overlay', as: 'dashboard_target'
  end

  resources :timeline_events, only: %i[create destroy]

  scope 'founder/facebook', as: 'founder_facebook', controller: 'founders/facebook_connect' do
    post 'connect'
    get 'connect_callback'
    post 'disconnect'
  end

  scope 'founder/slack', as: 'founder_slack', controller: 'founders/slack_connect' do
    get 'connect'
    get 'callback'
    post 'disconnect'
  end

  # TODO: Remove these startup routes as we no longer have 'startups'. Always use the corresponding 'product' routes below.
  resource :startup, only: %i[edit update] do
    member do
      post 'level_up'
      get 'billing'
    end
  end

  resources :startups, only: %i[index] do
    member do
      get 'events/:page', action: 'paged_events', as: 'paged_events'

      # TODO: Preserve this path for a while to allow old shares to work. This has been replaced by timeline_event_show path below.
      get ':event_title/:event_id', action: 'timeline_event_show'
    end
  end

  get 'startups/:id(/:slug)', to: 'startups#show', as: 'timeline'
  get 'startups/:id/:slug/e/:event_id/:event_title', to: 'startups#timeline_event_show', as: 'timeline_event_show'

  get 'product/edit', to: 'startups#edit', as: 'edit_product'

  scope 'products', controller: 'startups' do
    get '/', action: 'index', as: 'products'
    get '/:id(/:slug)', action: 'show', as: 'product'
    get '/:id/:slug/e/:event_id/:event_title', action: 'timeline_event_show', as: 'product_timeline_event_show'
  end

  resources :timeline_event_files, only: [] do
    member do
      get 'download'
    end
  end

  scope 'about', as: 'about', controller: 'about' do
    get '/', action: 'index'
    get 'slack'
    get 'media-kit'
    get 'leaderboard'
    get 'contact'
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

  scope 'coaches', module: 'coaches', controller: 'dashboard' do
    get 'dashboard', action: 'index'
  end

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

  scope 'talent', as: 'talent', controller: 'talent' do
    get '/', action: 'index'
    post 'contact'
  end

  get 'join', to: redirect('/apply')
  get 'apply', to: 'admissions#apply'
  post 'apply', to: 'admissions#register'

  scope 'admissions', as: 'admissions', controller: 'admissions' do
    get 'screening'
    get 'screening_submit'
    post 'screening_submit_webhook'
    post 'coupon_submit'
    patch 'coupon_remove'
    get 'team_members'
    post 'team_members', action: 'team_members_submit'
    post 'team_lead'
    get 'accept_invitation'
    patch 'update_founder'
  end

  resources :prospective_applicants, only: %i[create]

  resources :colleges, only: :index

  resource :platform_feedback, only: %i[create]

  # Redirect + webhook from Instamojo
  scope 'instamojo', as: 'instamojo', controller: 'instamojo' do
    get 'redirect'
    post 'webhook'
  end

  # Custom founder profile page.
  # # TODO: Remove this founder route as we no longer have 'founders'. Always use the corresponding 'student' route below.
  get 'founders/:slug', to: 'founders#founder_profile', as: 'founder_profile'

  get 'students/:slug', to: 'founders#founder_profile', as: 'student_profile'

  # Story of startup village, accessed via about pages.
  get 'story', as: 'story', to: 'home#story'

  # Previous transparency page re-directed to story
  get 'transparency', to: redirect('/story')

  # Application process tour of SV.CO
  get 'tour', to: 'home#tour'

  # Facebook School of Innovation at SV.CO landing page
  get 'fb', to: 'home#fb'
  get 'fb/apply', to: redirect('fb?apply=now')

  root 'home#index'

  # /slack redirected to /about/slack
  get '/slack', to: redirect('/about/slack')

  get '/dashboard', to: redirect('/student/dashboard')

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
  end

  resources :targets, only: [] do
    get 'select2_search', on: :collection

    member do
      get 'download_rubric'
      get 'prerequisite_targets'
      get 'startup_feedback'
      get 'details'
      post 'auto_verify'
    end
  end

  scope 'paytm', as: 'paytm', controller: 'paytm' do
    get 'pay'
    post 'callback'
  end

  # Public change log
  scope 'changelog', as: 'changelog', controller: 'changelog' do
    get 'archive'
    get '(/:year)', action: 'index'
  end

  resource :impersonation, only: %i[destroy]

  # TODO: Remove this route once PayTM is correctly configured with '/paytm/callback' as the redirect_url.
  post '/', to: 'home#paytm_callback'

  scope 'intercom', as: 'intercom', controller: 'intercom' do
    post 'user_create', action: 'user_create_webhook'
    post 'unsubscribe', action: 'email_unsubscribe_webhook'
  end

  # Handle incoming interaction requests from Slack
  post '/slack/interaction_webhook', to: 'slack#interaction_webhook'

  match '/trello/bug_webhook', to: 'trello#bug_webhook', via: :all

  post '/heroku/deploy_webhook', to: 'heroku#deploy_webhook'

  # Handle incoming unsubscribe webhooks from SendInBlue
  post '/send_in_blue/unsubscribe', to: 'send_in_blue#unsubscribe_webhook'

  # Handle redirects of short URLs.
  get 'r/:unique_key', to: 'shortened_urls#redirect', as: 'short_redirect'

  scope 'stats', controller: 'product_metrics' do
    get '/', action: 'index', as: 'stats'
  end

  # Handle shortener-gem form URLs for a while (backward compatibility).
  get '/:unique_key', to: 'shortened_urls#redirect', constraints: { unique_key: /[0-9a-z]{5}/ }
end
