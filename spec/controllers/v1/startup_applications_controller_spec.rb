require 'spec_helper'

describe V1::StartupApplicationsController do

  describe "POST 'startup_application'" do
  	context "with valid attributes" do
	    it "returns http success" do
	      post :create, startup_application: attributes_for(:startup_application)
	      expect(response).to be_success
	    end
    end
  end

end
