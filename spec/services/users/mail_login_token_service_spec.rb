require 'rails_helper'

describe Users::MailLoginTokenService do
  subject { described_class.new(school, domain, user, referer, shared_device) }

  let(:user) { create :user }
  let(:school) { create :school }
  let(:domain) { create :domain, :primary, school: school }
  let(:shared_device) { [true, false].sample }
  let(:referer) { Faker::Internet.url(domain.fqdn) }

  describe '#execute' do
    it 'generates new login token' do
      expect do
        subject.execute
      end.to(change { user.reload.login_token })
    end

    it 'emails login link to user' do
      subject.execute

      open_email(user.email)

      expect(current_email.subject).to eq("Log in to #{school.name}")
      expect(current_email.body).to include("https://#{domain.fqdn}/users/token?")
      expect(current_email.body).to include("referer=#{CGI.escape(referer)}")
      expect(current_email.body).to include("token=#{user.reload.login_token}")
    end

    context 'when there is no school, domain, or referer' do
      let(:school) { nil }
      let(:domain) { nil }
      let(:referer) { nil }

      it 'uses default school name and domain' do
        subject.execute

        open_email(user.email)

        expect(current_email.subject).to eq("Log in to PupilFirst")
        expect(current_email.body).to include('https://www.pupilfirst.com/users/token?')
        expect(current_email.body).not_to include('referer=')
      end
    end
  end
end
