require 'rails_helper'

describe PartnershipsController do
  describe "GET 'confirm'" do
    context 'when passed an invalid confirmation token'
    it 'returns HTTP Not Found' do
      expect {
        get :show_confirmation, confirmation_token: 'foobar'
      }.to raise_error ActionController::RoutingError
    end
  end
end
