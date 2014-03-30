require 'spec_helper'

describe V1::UsersController do

  describe "POST 'forgot_password'" do
    context 'with an invalid email id' do
      it "returns http status 422" do
        post :forgot_password, email: "wrong email"
        expect(response.status).to equal(422)
      end
    end
    context "with valid email id" do
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
