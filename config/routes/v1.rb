Svapp::Application.routes.draw do
  scope '/api' do
    api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.svapp.v1"}, :defaults => {:format => "json"}, :default => true) do
      resources :users do
        resource :student_entrepreneur_policy

        member do
          post 'phone_number_verification', to: :generate_phone_number_verification_code
          patch 'phone_number_verification', to: :verify_phone_number
        end

        collection do
          resources :sessions, only: [:create]
          post :forgot_password
        end
      end
      resources :events
      resources :news
      resources :startups do
        resources :banks
        collection do
          get :load_suggestions
        end
        member do
          post :link_employee
          post :partnership_application
        end
      end
      get '/mentors' => 'info#mentors'
      get '/advisory-council' => 'info#advisory_council'
      get '/startup_stats' => 'info#startup_stats'
    end
  end
end
