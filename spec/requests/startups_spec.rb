require 'spec_helper'

describe "Startups" do
  include V1ApiSpecHelper

  # describe "GET /startups" do
  #   it "works! (now write some real specs)" do
  #     # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
  #     get "/api/startups"
  #     expect(response.status).to eq(200)
  #   end
  # end

  describe "Accept GET on confirm_employee" do
    let(:startup) { create :startup }
    let(:new_employee){ create :employee, {startup_link_verifier_id: nil, startup: startup}}
    before(:each) do
      founder = startup.founders.first
      login(founder)
      allow(Urbanairship).to receive(:push).and_return true
      post "/startups/#{startup.id}/confirm_employee", {token: new_employee.startup_verifier_token, is_founder: true}
    end

    it "responds with 200 status" do
      expect(response.status).to eql(200)
    end

    it "assigns requested employee to startup" do
      new_employee.reload
      expect(startup.employees).to include(new_employee)
      expect(new_employee.is_founder).to be(true)
    end

  end
end
