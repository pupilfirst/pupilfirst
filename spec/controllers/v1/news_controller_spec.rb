require 'spec_helper'

describe V1::NewsController do

  describe "GET 'news'" do
    context "with valid attributes" do
      it "returns http success" do
        n = create(:news, youtube_id: 'foobar')
        request.accept = "application/json"
        get :index
        expect(response).to be_success
      end
    end
  end

end
