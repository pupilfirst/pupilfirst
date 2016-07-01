require 'rails_helper'

RSpec.describe SixWaysMoocController, type: :controller do
  describe "GET #identify" do
    it "returns http success" do
      get :identify
      expect(response).to have_http_status(:success)
    end
  end
end
