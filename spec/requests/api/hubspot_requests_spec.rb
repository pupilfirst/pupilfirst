require 'rails_helper'

module Api
  describe 'Hubspot endpoint' do
    let(:user_email) { 'test@test.com' }
    def access_token(request_body)
      ::Digest::SHA256.hexdigest(
        [
          Rails.application.secrets.hubspot[:client_secret],
          request_body.to_s
        ].join
      )
    end
    def headers(request_body)
      {
        'ACCEPT' => 'application/json',
        "CONTENT_TYPE" => "application/json",
        'X-HubSpot-Signature-Version' => 'v1',
        'X-HubSpot-Signature' => access_token(request_body)
      }
    end
    let(:domain) { create :domain, fqdn: host, primary: true }
    let(:user) { create :user, name: 'Test Test', email: user_email, school: domain.school }

    def payload(mvp)
      [
        {
          eventId: "100",
          subscriptionId: 130032,
          portalId: 5940454,
          occurredAt: 1617874455120,
          subscriptionType: "contact.propertyChange",
          attemptNumber: 0,
          objectId: 123,
          changeSource: "CRM",
          propertyName: "mvp",
          propertyValue: mvp.to_s
        }
      ]
    end

    it 'toggle mvp tag for user' do
      user # setup user & school

      params = payload(true).to_json
      post "/api/hubspot", params: params, headers: headers(params)
      expect(response).to have_http_status(:ok)
    end
  end
end