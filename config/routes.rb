Svapp::Application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)

  devise_for(:users,
    controllers: {
      passwords: 'users/passwords',
      invitations: 'users/invitations',
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }
  )

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :users, only: [:show, :edit, :update] do
    resources :mentor_meetings, only: ['index']

    member do
      get 'phone'
      post 'code'
      patch 'resend'
      post 'verify'
    end

    collection do
      patch 'update_password'
      get 'invite'
      post 'send_invite'
    end
  end

  resources :startups, except: [:create] do
    # resources :startup_jobs do
    #   patch :repost
    # # resources :founders do
    # # collection do
    # #   post :invite
    # # end
    # end

    member do
      post :add_founder
    end
  end

  resources :mentors do
    resources :mentor_meetings, only: %w(new create)
  end

  scope 'mentor_meetings', as: 'mentor_meetings', controller: 'mentor_meetings' do
    patch ':id/start', action: 'start', as: 'start'
    patch ':id/reject', action: 'reject', as: 'reject'
    patch ':id/accept', action: 'accept', as: 'accept'
    get ':id', action: 'live', as: 'live'
    get ':id/feedback', action: 'feedback', as: 'feedback'
    patch ':id/feedbacksave', action: 'feedbacksave', as: 'feedbacksave'
    get ':id/reminder', action: 'reminder', as: 'reminder'
    patch ':id/reschedule', action: 'reschedule', as: 'reschedule'
    patch ':id/cancel', action: 'cancel', as: 'cancel'
  end

  scope 'mentoring', as: 'mentoring', controller: 'mentoring' do
    get '/', action: 'index'
    get 'register', action: 'new_step1'
    post 'register'
    get 'register_2', action: 'new_step2'
    post 'register_2'
    get 'register_3', action: 'new_step3'
    post 'register_3'
    get 'register_4', action: 'new_step4'
    post 'register_4'
    get 'sign_up', action: 'sign_up_form'
    post 'sign_up'
    patch 'resend', action: 'resend'
  end

  # get 'jobs', to: 'startup_jobs#list_all'

  resources :incubation, only: %w(show update) do
    member do
      post 'add_cofounder'
    end
  end

  root 'home#index'
end
