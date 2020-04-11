require 'rails_helper'

describe 'Postmark webhook bounce reports' do
  include HttpBasicAuthHelper

  let(:user_1) { create :user }
  let!(:user_2) { create :user }

  before(:all) do
    ENV['POSTMARK_HOOK_ID'] = 'hook_id_for_test'
    ENV['POSTMARK_HOOK_SECRET'] = 'hook_secret_for_test'
    @headers = request_spec_headers('hook_id_for_test', 'hook_secret_for_test')
  end

  context 'when postmark reports hard-bounce for a user' do
    it 'creates a bounce report of type hard-bounced' do
      expect do
        post '/users/email_bounce', params: { Email: user_1.email, Type: 'HardBounce' }, headers: @headers
      end.to change { BounceReport.where(email: user_1.email).count }.from(0).to(1)

      bounce_report = BounceReport.find_by(email: user_1.email)
      expect(bounce_report.bounce_type).to eq('HardBounce')
      expect(response.code).to eq("200")
    end
  end

  context 'when postmark reports spam-complaint from a user' do
    it 'marks email as bounced with appropriate bounce type' do
      post '/users/email_bounce', params: { Email: user_1.email, Type: 'SpamComplaint' }, headers: @headers

      expect(response.code).to eq("200")

      bounce_report = BounceReport.find_by(email: user_1.email)
      expect(bounce_report.bounce_type).to eq('SpamComplaint')
    end
  end

  context 'when postmark reports some complaint from a user who is not registered' do
    it 'saves the bounce report' do
      post '/users/email_bounce', params: { Email: "missinguser@example.com", Type: 'HardBounce' }, headers: @headers
      expect(response.code).to eq("200")

      # No bounce report created for the unknown email
      expect(BounceReport.where(email: "missinguser@example.com").count).to eq(1)

      # None of the users should have been marked bounced.
      expect(BounceReport.where(email: user_1.email).count).to eq(0)
      expect(BounceReport.where(email: user_2.email).count).to eq(0)
    end
  end

  context 'when postmark reports a webhook of a type that is unhandled' do
    it 'ignores the request' do
      post '/users/email_bounce', params: { Email: user_1.email, Type: 'Delivery' }, headers: @headers

      expect(response.code).to eq("200")

      # None of the emails should have been marked bounced.
      expect(BounceReport.where(email: user_1.email).count).to eq(0)
      expect(BounceReport.where(email: user_2.email).count).to eq(0)
    end
  end

  context 'when postmark reports some complaint with incorrect credentials' do
    it 'rejects the request' do
      post '/users/email_bounce', params: { Email: user_1.email, Type: 'HardBounce' }
      expect(response.code).to eq("401")

      # None of the users should have been marked bounced.
      expect(BounceReport.where(email: user_1.email).count).to eq(0)
      expect(BounceReport.where(email: user_2.email).count).to eq(0)
    end
  end
end
