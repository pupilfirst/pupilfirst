require 'rails_helper'

describe Users::MailUpdateEmailTokenService do
  subject { described_class.new(user, new_email) }

  let(:school) { create :school, :current }
  let(:user) { create :user, school: school }
  let(:domain) { school.domains.where(primary: true).first }
  let(:new_email) { Faker::Internet.email }

  context 'When an User is passed on to the service' do
    subject { described_class.new(user, new_email) }

    describe '#execute' do
      it 'generates new update email token for user' do
        subject.execute
        expect(user.update_email_token).not_to eq nil
      end

      it 'emails update email token to user' do
        subject.execute

        open_email(new_email)

        expect(current_email.subject).to eq(
          "Update your email address in #{school.name} school"
        )
        expect(current_email.body).to include(
          "https://#{domain.fqdn}/users/update_email?token="
        )
      end
    end
  end
end
