Svapp::Application.routes.draw do
  scope '/api' do
    api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.svapp.v1"}, :defaults => {:format => "json"}, :default => true) do
      resources :users do
        resource :student_entrepreneur_policy

        member do
          post 'phone_number', to: :generate_phone_number_verification_code
          put 'phone_number', to: :verify_phone_number
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
          post :founders, to: :add_founder
          delete :founders, to: :delete_founder
          get :founders, to: :retrieve_founder
          post :incubate
        end
      end

      get '/mentors' => 'info#mentors'
      get '/advisory-council' => 'info#advisory_council'
      get '/startup_stats' => 'info#startup_stats'
    end
  end
end
