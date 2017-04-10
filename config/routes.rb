Rails.application.routes.draw do
  devise_for :users, only: %i(sessions omniauth_callbacks), controllers: { sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks' }

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

  resource :founder, only: %i(edit update) do
    member do
      scope module: 'founders', controller: 'dashboard' do
        get 'dashboard'
        post 'startup_restart'
      end
    end

    resource :startup, only: %i(edit update) do
      scope module: 'founders', controller: 'dashboard' do
        post 'level_up'
      end

      resources :timeline_events, only: %i(create destroy update)
      resources :team_members, except: %i(index)
    end
  end

  scope 'founder/facebook', as: 'founder_facebook', controller: 'founders/facebook_connect' do
    post 'connect'
    get 'connect_callback'
    post 'disconnect'
  end

  resources :startups, only: %i(index show) do
    collection do
      post 'team_leader_consent'
    end

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

  resources :faculty, only: %i(index show) do
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
    get ':id/join_session(/:token)', action: 'join_session', as: 'join_session'
  end

  scope 'talent', as: 'talent', controller: 'talent' do
    get '/', action: 'index'
    post 'contact'
  end

  get 'apply', to: 'admissions#apply'
  post 'apply', to: 'admissions#register'

  scope 'admissions', as: 'admissions', controller: 'admissions' do
    get 'screening'
    post 'screening', action: 'screening_submit'
    get 'fee'
    post 'fee', action: 'fee_submit'
    post 'coupon_submit'
    patch 'coupon_remove'
    get 'founders'
    post 'founders', action: 'founders_submit'
    get 'accept_invitation'
    get 'preselection'
    patch 'preselection', action: 'preselection_submit'
    patch 'update_founder'
    get 'partnership_deed'
    get 'incubation_agreement'
  end

  scope 'apply', as: 'apply', controller: 'batch_application' do
    get '', action: 'index'
    post 'register'
    post 'notify'
    get 'continue'
    post 'restart', action: 'restart_application'
    get 'cofounders', action: 'cofounders_form'
    post 'cofounders', action: 'cofounders_save'
    post 'coupon_submit'
    patch 'coupon_remove'

    scope 'stage/:stage_number', as: 'stage' do
      get '', action: 'ongoing'
      post 'submit'
      patch 'submit'
      get 'complete'
      post 'restart'
      get 'expired'
      get 'rejected'
    end

    scope 'stage/6', as: 'pre_selection_stage' do
      get 'partnership_deed'
      get 'incubation_agreement'
      patch 'update_applicant'
    end
  end

  # webhook url for intercom user create - used to strip them off user_id
  post 'intercom_user_create', controller: 'intercom', action: 'user_create'

  resources :universities, only: :index
  resources :colleges, only: :index

  resource :platform_feedback, only: %i(create)

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

  # Public Changelog.
  get 'changelog', to: 'home#changelog'

  # Application process tour of SV.CO
  get 'tour', to: 'home#tour'

  root 'home#index'

  # custom defined 404 route to use with shortener gem's config
  get '/404', to: 'home#not_found'

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
    member do
      get 'download_rubric'
    end
  end

  scope 'paytm', as: 'paytm', controller: 'paytm' do
    get 'pay'
    post 'callback'
  end

  resource :impersonation, only: %i(destroy)

  # TODO: Remove this route once PayTM is correctly configured with '/paytm/callback' as the redirect_url.
  post '/', to: 'home#paytm_callback'

  # used for shortened urls from the shortener gem
  get '/:id', to: 'shortener/shortened_urls#show'

  match '/trello/bug_webhook', to: 'trello#bug_webhook', via: :all

  post '/heroku/deploy_webhook', to: 'heroku#deploy_webhook'
end
