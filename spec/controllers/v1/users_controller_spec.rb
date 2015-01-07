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
        allow(User).to receive(:find_by_email).with(mock_user.email).and_return(mock_user)
        expect(mock_user).to receive(:send_reset_password_instructions)
        post :forgot_password, email: mock_user.email
        expect(response).to be_success
      end
    end
  end

end
