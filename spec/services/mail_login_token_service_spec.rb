require 'rails_helper'

describe MailLoginTokenService do
  subject { described_class.new(user, referrer, shared_device) }

  let(:school) { create :school, :current }
  let(:user) { create :user, school: school }
  let(:shared_device) { [true, false].sample }
  let(:domain) { school.domains.where(primary: true).first }
  let(:referrer) { Faker::Internet.url(host: domain.fqdn) }

  context 'When an User is passed on to the service' do
    subject { described_class.new(user, referrer, shared_device) }

    describe '#execute' do
      it 'generates new login token for user' do
        expect {user.original_login_token}.to raise_error(RuntimeError, "Original login token is unavailable")
        subject.execute
        expect(user.original_login_token).not_to eq nil
      end

      it 'emails login link to user' do
        subject.execute

        open_email(user.email)

        expect(current_email.subject).to eq("Log in to #{school.name}")
        expect(current_email.body).to include("http://#{domain.fqdn}/users/token?")
        expect(current_email.body).to include("referrer=#{CGI.escape(referrer)}")
        expect(current_email.body).to include("#{user.login_token_expiration_time}")
        expect(current_email.body).to include("token=#{user.original_login_token}")
      end
    end
  end
end
