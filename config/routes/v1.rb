Svapp::Application.routes.draw do
  scope '/api' do
	  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.svapp.v1"}, :defaults => {:format => "json"}, :default => true) do
	    resources :users do
	    	collection do
	    		resources :sessions, only: [:create]
	    		post :forgot_password
	    	end
	    end
	    resources :events
	    resources :news
	    resources :startups do
	    	collection do
	    		get :load_suggestions
	    	end
        member do
          post :link_employee
        end
	    end
      get '/mentors' => 'info#mentors'
      get '/advisory-council' => 'info#advisory_council'
      get '/startup_stats' => 'info#startup_stats'
	  end
  end
end
