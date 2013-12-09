Svapp::Application.routes.draw do
  scope '/api' do
	  api_version(:module => "V1", :header => {:name => "Accept", :value => "application/vnd.svapp.v1"}, :defaults => {:format => "json"}, :default => true) do
	    resources :events
	    resources :news
	  end
  end
end
