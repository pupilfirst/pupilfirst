require 'spec_helper'

describe V1::EventsController do

  describe "GET 'events'" do
    context "with valid attributes" do
      it "returns http success" do
        n = create(:event)
        request.accept = "application/json"
        get :index
        expect(response).to be_success
      end
    end
  end

end
