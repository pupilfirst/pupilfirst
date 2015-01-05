require 'spec_helper'

describe 'Startups' do
  include V1ApiSpecHelper

  describe 'GET /confirm_employee' do
    let(:startup) { create :startup }
    let(:new_employee){ create :employee, {startup_link_verifier_id: nil, startup: startup}}

    before(:each) do
      founder = startup.founders.first
      #founder.confirm!
      login(founder)

      allow(UserPushNotifyJob).to receive_message_chain(:new, :async, :perform).and_return(true)
      allow(Urbanairship).to receive(:push).and_return true
      post "/startups/#{startup.id}/confirm_employee", {token: new_employee.startup_verifier_token, is_founder: true}
    end

    it 'responds with 200 status' do
      expect(response.status).to eql(200)
    end

    it 'assigns requested employee to startup' do
      new_employee.reload
      expect(startup.employees).to include(new_employee)
      expect(new_employee.is_founder).to be(true)
    end

  end
end
