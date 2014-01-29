require 'spec_helper'

describe "Startups" do
  describe "GET /startups" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get "/api/startups"
      expect(response.status).to eq(200)
    end
  end
end
