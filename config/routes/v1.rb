Svapp::Application.routes.draw do
  scope '/api' do
    api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.svapp.v1"}, :defaults => {:format => "json"}, :default => true) do
      resources :users do
        resource :student_entrepreneur_policy

        member do
          post 'phone_number', action: :generate_phone_number_verification_code
          put 'phone_number', action: :verify_phone_number
          put 'cofounder_invitation', action: :accept_cofounder_invitation
          delete 'cofounder_invitation', action: :reject_cofounder_invitation
          get 'contacts', action: :connected_contacts
          post 'contacts', action: :connect_contact
        end

        collection do
          resources :sessions, only: [:create]
          post :forgot_password
        end
      end

      resources :requests, only: [:index, :create]
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
          post :founders, action: :add_founder
          delete :founders, action: :delete_founder
          get :founders, action: :retrieve_founder
          post :incubate
          post :registration
        end
      end

      resources :categories, only: [:index]

      get '/mentors' => 'info#mentors'
      get '/advisory-council' => 'info#advisory_council'
      get '/startup_stats' => 'info#startup_stats'
    end
  end
end
