require 'rails_helper'

describe 'Postmark webhook bounce reports' do
  include HttpBasicAuthHelper

  let(:user_1) { create :user }
  let!(:user_2) { create :user }
  let(:another_school) { create :school }
  let!(:user_1_s2) { create :user, email: user_1.email, school: another_school }

  before(:all) do
    ENV['POSTMARK_HOOK_ID'] = 'hook_id_for_test'
    ENV['POSTMARK_HOOK_SECRET'] = 'hook_secret_for_test'
    @headers = request_spec_headers('hook_id_for_test', 'hook_secret_for_test')
  end

  context 'when postmark reports hard-bounce for a user in multiple schools' do
    it 'marks all matching users in all schools as hard-bounced' do
      expect do
        post '/users/email_bounce', params: { Email: user_1.email, Type: 'HardBounce' }, headers: @headers
      end.to change { user_1.reload.email_bounced_at }.from(nil)

      expect(response.code).to eq("200")

      # Both users in different schools with the reported email should be marked bounced.
      expect(user_1.email_bounce_type).to eq('HardBounce')
      expect(user_1_s2.reload.email_bounced_at).not_to eq(nil)
      expect(user_1_s2.email_bounce_type).to eq('HardBounce')

      # User with different email should have been left alone.
      expect(user_2.reload.email_bounced_at).to eq(nil)
      expect(user_2.email_bounce_type).to eq(nil)
    end
  end

  context 'when postmark reports spam-complaint from a user in multiple schools' do
    it 'marks all matching users in all schools as bounced with appropriate bounce type' do
      post '/users/email_bounce', params: { Email: user_1.email, Type: 'SpamComplaint' }, headers: @headers

      expect(response.code).to eq("200")

      # Both users in different schools with the reported email should be marked bounced with the correct bounce type.
      expect(user_1.reload.email_bounced_at).not_to eq(nil)
      expect(user_1.email_bounce_type).to eq('SpamComplaint')
      expect(user_1_s2.reload.email_bounced_at).not_to eq(nil)
      expect(user_1_s2.email_bounce_type).to eq('SpamComplaint')

      # User with different email should have been left alone.
      expect(user_2.reload.email_bounced_at).to eq(nil)
      expect(user_2.email_bounce_type).to eq(nil)
    end
  end

  context 'when postmark reports some complaint from a user who is not registered' do
    it 'ignores the request' do
      post '/users/email_bounce', params: { Email: "missinguser@example.com", Type: 'HardBounce' }, headers: @headers
      expect(response.code).to eq("200")

      # None of the users should have been marked bounced.
      expect(user_1.reload.email_bounced_at).to eq(nil)
      expect(user_1_s2.reload.email_bounced_at).to eq(nil)
      expect(user_2.reload.email_bounced_at).to eq(nil)
    end
  end

  context 'when postmark reports a webhook of a type that is unhandled' do
    it 'ignores the request' do
      post '/users/email_bounce', params: { Email: user_1.email, Type: 'Delivery' }, headers: @headers

      expect(response.code).to eq("200")

      # None of the users should have been marked bounced.
      expect(user_1.reload.email_bounced_at).to eq(nil)
      expect(user_1_s2.reload.email_bounced_at).to eq(nil)
      expect(user_2.reload.email_bounced_at).to eq(nil)
    end
  end

  context 'when postmark reports some complaint with incorrect credentials' do
    it 'rejects the request' do
      post '/users/email_bounce', params: { Email: user_1.email, Type: 'HardBounce' }
      expect(response.code).to eq("401")

      # None of the users should have been marked bounced.
      expect(user_1.reload.email_bounced_at).to eq(nil)
      expect(user_1_s2.reload.email_bounced_at).to eq(nil)
      expect(user_2.reload.email_bounced_at).to eq(nil)
    end
  end
end
