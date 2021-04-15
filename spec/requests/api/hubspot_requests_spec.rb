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
    let(:school) { domain.school }
    let(:user) { create :user, name: 'Test Test', email: user_email, school: school }
    let(:mvp_user) {
      user.tap do |u|
        u.tag_list.add('mvp')
        u.school.user_tag_list.add('mvp')
        u.school.save!
        u.save!
      end
    }

    def payload(mvp, object_id: 123)
      [
        {
          eventId: "100",
          subscriptionId: 130032,
          portalId: 5940454,
          occurredAt: 1617874455120,
          subscriptionType: "contact.propertyChange",
          attemptNumber: 0,
          objectId: object_id,
          changeSource: "CRM",
          propertyName: "mvp",
          propertyValue: mvp.to_s
        }
      ]
    end

    it 'set mvp tag for user' do
      user # setup user & school

      params = payload(true).to_json
      expect {
        post "/api/hubspot", params: params, headers: headers(params)
      }.to change { user.reload.tag_list }.from([]).to(['mvp'])
      expect(response).to have_http_status(:ok)

      expect(school.reload.user_tag_list).to match(['mvp'])
    end

    it 'remove mvp tag for user' do
      mvp_user # setup user & school

      params = payload(false).to_json
      expect {
        post "/api/hubspot", params: params, headers: headers(params)
      }.to change { mvp_user.reload.tag_list }.from(['mvp']).to([])
      expect(response).to have_http_status(:ok)

      expect(school.reload.user_tag_list).to match([])
    end

    it 'no op for user already tagged with mvp tag' do
      mvp_user # setup user & school

      params = payload(true).to_json
      expect {
        post "/api/hubspot", params: params, headers: headers(params)
      }.not_to change(mvp_user, :tag_list)
      expect(response).to have_http_status(:ok)

      expect(school.reload.user_tag_list).to match(['mvp'])
    end

    it 'no op when user is not yet tagged with mvp tag' do
      user # setup user & school

      params = payload(false).to_json
      expect {
        post "/api/hubspot", params: params, headers: headers(params)
      }.not_to change(user, :tag_list)
      expect(response).to have_http_status(:ok)

      expect(school.reload.user_tag_list).to match([])
    end

    it 'responds with error of no Hubspot::Contact' do
      user # setup user & school

      params = payload(true, object_id: 234).to_json
      expect {
        post "/api/hubspot", params: params, headers: headers(params)
      }.not_to change(user, :tag_list)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to match(/Unable to fetch contact for id: 234/)
    end
  end
end