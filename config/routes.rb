Rails.application.routes.draw do
  devise_for :users, only: [:sessions, :omniauth_callbacks], controllers: { sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks' }

  devise_scope :user do
    post 'users/send_login_email', controller: 'users/sessions', action: 'send_login_email', as: 'user_send_login_email'
    get 'users/token', controller: 'users/sessions', action: 'token', as: 'user_token'
  end

  authenticated :admin_user do
    mount Delayed::Web::Engine, at: '/jobs'
  end

  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resource :founder, only: [:edit, :update] do
    resource :startup, only: [:edit, :update, :destroy] do
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
    get ':id/join_session(/:token)', action: 'join_session', as: 'join_session'
  end

  scope 'talent', as: 'talent', controller: 'talent' do
    get '/', action: 'index'
    post 'contact'
  end

  scope 'apply', as: 'apply', controller: 'batch_application' do
    get '', action: 'index'
    post 'register'
    post 'notify'
    get 'identify'
    post 'send_sign_in_email'
    get 'sign_in_email_sent'
    get 'continue'
    get 'batch_pending'
    post 'restart', action: 'restart_application'
    get 'cofounders', action: 'cofounders_form'
    post 'cofounders', action: 'cofounders_save'

    # TODO: Remove this after batch 3 intake is complete. Added to account for emails sent out before application process was overhauled.
    get 'identify/3', to: redirect('/apply')

    scope 'stage/:stage_number', as: 'stage' do
      get '', action: 'ongoing'
      post 'submit'
      patch 'submit'
      get 'complete'
      post 'restart'
      get 'expired'
      get 'rejected'
    end

    scope 'stage/4', as: 'stage_4' do
      get 'partnership_deed'
      get 'incubation_agreement'
      patch 'update_applicant'
    end
  end

  # webhook url for intercom user create - used to strip them off user_id
  post 'intercom_user_create', controller: 'intercom', action: 'user_create'

  resources :universities, only: :index
  resources :colleges, only: :index

  resource :platform_feedback, only: [:create]

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

  # Activity from startups.
  get 'activity', as: 'activity', to: 'timeline_events#activity'

  # Public Changelog.
  get 'changelog', to: 'home#changelog'

  # Application process tour of SV.CO
  get 'tour', to: 'home#tour'

  root 'home#index'

  # custom defined 404 route to use with shortener gem's config
  get '/404', to: 'home#not_found'

  # Previous sixways page re-directed to startincollege
  # get 'sixways', to: redirect('/startincollege')

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

  # used for shortened urls from the shortener gem
  get '/:id', to: 'shortener/shortened_urls#show'
end
