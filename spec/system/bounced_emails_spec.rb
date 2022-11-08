require 'rails_helper'

feature 'Prevent mail delivery to bounced addresses' do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create :user }

  context "when the user's email address is not a bounced address" do
    scenario 'the email can delivered now' do
      UserMailer.account_deletion_notification(user, 'http://example.com', 24)
        .deliver_now

      open_email(user.email)

      expect(current_email.subject).to eq(
        "Your account in #{user.school.name} will be deleted in 30 days"
      )
    end

    scenario 'the email can delivered later' do
      UserMailer.account_deletion_notification(user, 'http://example.com', 24)
        .deliver_later

      open_email(user.email)

      expect(current_email.subject).to eq(
        "Your account in #{user.school.name} will be deleted in 30 days"
      )
    end
  end

  context 'when the user has a bounce report' do
    let!(:bounce_report) { create :bounce_report, email: user.email }

    scenario 'user cannot be sent an email now' do
      UserMailer.account_deletion_notification(user, 'http://example.com', 24)
        .deliver_now

      open_email(user.email)

      expect(current_email).to be_nil
    end

    scenario 'user cannot be sent an email later' do
      UserMailer.account_deletion_notification(user, 'http://example.com', 24)
        .deliver_later

      open_email(user.email)

      expect(current_email).to be_nil
    end
  end
end
