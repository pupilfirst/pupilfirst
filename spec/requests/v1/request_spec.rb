require 'spec_helper'

describe 'Request requests' do # :-)
  include V1ApiSpecHelper

  describe 'POST /api/requests' do
    let(:user) { create :founder, startup: create(:startup) }

    context 'when a user without startup creates request' do
      it 'responds with 422 UserDoesNotBelongToStartup' do
        post '/api/requests', {}, version_header
        expect(response.code).to eq '422'
        expect(parse_json response.body, 'code').to eq 'UserDoesNotBelongToStartup'
      end
    end

    context 'when a user with startup creates request' do
      it "creates a request in user's name" do
        post '/api/requests', { request: { body: 'REQUEST_BODY' } }, version_header(user)

        expect(response.code).to eq '200'
        request = Request.last
        expect(request.body).to eq 'REQUEST_BODY'
        expect(request.user).to eq user
      end
    end
  end

  describe 'GET /api/requests' do
    let(:user) { create :founder, startup: create(:startup) }

    it 'returns requests made by user' do
      r1 = create :request, user: user
      r2 = create :request, user: user
      create :request

      get '/api/requests', {}, version_header(user)
      parsed_response = parse_json response.body
      expect(parsed_response.length).to eq 2
      expect(parsed_response[0]['body']).to eq(r1.body)
      expect(parsed_response[1]['body']).to eq(r2.body)
    end
  end
end
