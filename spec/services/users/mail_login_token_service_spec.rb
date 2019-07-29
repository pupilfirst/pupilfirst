require 'rails_helper'

describe Users::MailLoginTokenService do
  subject { described_class.new(school, user, referer, shared_device) }

  let(:school) { create :school, :current }
  let(:user) { create :user, school: school }
  let(:shared_device) { [true, false].sample }
  let(:domain) { school.domains.where(primary: true).first }
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
  end
end
