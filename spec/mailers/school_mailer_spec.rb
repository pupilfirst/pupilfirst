require 'rails_helper'

describe SchoolMailer do
  describe 'email sender signature' do
    let(:user) { create :user, school: school }
    let(:mail) { UserSessionMailer.send_login_token(user, {}) }
    let(:name) { Faker::Name.name }
    let(:email) { Faker::Internet.email(name: name) }

    context 'when the school does not have a custom sender signature' do
      let(:school) { create :school, :current }

      it 'uses school name and default address as signature for emails' do
        expect(mail[:from].value).to eq("#{school.name} <test@example.com>")
      end
    end

    context 'when the school has an unconfirmed custom sender signature' do
      let(:school) { create :school, :current, configuration: { email_sender_signature: { name: name, email: email } } }

      it 'uses school name and default address as signature for emails' do
        expect(mail[:from].value).to eq("#{school.name} <test@example.com>")
      end
    end

    context 'when the school has a confirmed custom sender signature' do
      let(:school) { create :school, :current, configuration: { email_sender_signature: { name: name, email: email, confirmed_at: 1.day.ago.iso8601 } } }

      it 'uses the custom sender signature' do
        expect(mail[:from].value).to eq("#{name} <#{email}>")
      end
    end
  end
end
