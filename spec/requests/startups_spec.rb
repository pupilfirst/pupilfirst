require 'spec_helper'

describe "Startups" do
  include V1ApiSpecHelper

  describe "GET /startups" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get "/api/startups"
      expect(response.status).to eq(200)
    end
  end

  describe "Accept GET on confirm_employee" do
    before(:all) do
      @startup = create :startup
      @new_employee = create :employee, {startup_link_verifier_id: nil, startup: @startup}
      @founder = @startup.founders.first
      login(@founder)
      get "/startups/#{@startup.id}/confirm_employee", {token: @new_employee.startup_verifier_token}
    end

    it "responds with 201 status" do
      expect(response.status).to eql(201)
    end

    it "assigns requested employee to startup" do
      employees_ids = @startup.reload.employees.map &:id
      expect(employees_ids).to include(@new_employee.id)
    end

    it "assigns one of the founder as verifier" do
      expect(@new_employee.reload.startup_link_verifier.id).to eql(@founder.id)
    end
  end
end
