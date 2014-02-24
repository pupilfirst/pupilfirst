require 'spec_helper'

describe V1::UsersController do

  describe "POST 'forgot_password'" do
  	context "with email id" do
	    it "returns http success and sends an email" do
	    	mock_user = double("User", send_reset_password_instructions: true, email: 'foo@bar.com')
	    	User.stub(:find_by_email).with(mock_user.email) { mock_user }
		    mock_user.should_receive(:send_reset_password_instructions)
		    post :forgot_password, email: mock_user.email
		    expect(response).to be_success
	    end
    end
  end

end
