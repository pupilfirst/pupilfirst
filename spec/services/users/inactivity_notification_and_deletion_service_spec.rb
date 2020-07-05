require 'rails_helper'

describe Users::InactivityNotificationAndDeletionService do
  include ActiveSupport::Testing::TimeHelpers
  subject { described_class.new }

  # Setup the basics
  let(:school_1) { create :school, configuration: { 'delete_inactive_users_after' => 4 } }
  let!(:domain_school_1) { create :domain, school: school_1, primary: true, fqdn: 'school1.host' }
  let(:school_2) { create :school }
  let!(:domain_school_2) { create :domain, school: school_2, primary: true, fqdn: 'school2.host' }

  # Users in school_1
  let!(:active_user_school_1) { create :user, school: school_1, last_sign_in_at: 3.days.ago }
  let!(:inactive_user_school_1) { create :user, school: school_1, last_sign_in_at: 100.days.ago }
  let!(:notified_user_school_1) { create :user, school: school_1, last_sign_in_at: 5.months.ago, account_deletion_notification_sent_at: 32.days.ago }
  let!(:reactivated_user_school_1) { create :user, school: school_1, last_sign_in_at: 2.days.ago, account_deletion_notification_sent_at: 32.days.ago }

  # Users in school_2
  let!(:active_user_school_2) { create :user, school: school_2, last_sign_in_at: 3.days.ago }
  let!(:inactive_user_school_2) { create :user, school: school_2, last_sign_in_at: 100.days.ago }

  describe '#execute' do
    context 'inactivity configuration for user deletion is absent in environment' do
      around do |example|
        original_value = Rails.application.secrets.delete_inactive_users_after
        Rails.application.secrets.delete_inactive_users_after = 0

        example.run

        Rails.application.secrets.delete_inactive_users_after = original_value
      end
      it 'sends notification and deletes users only in school with configuration' do
        subject.execute

        # Check emails of all users
        open_email(inactive_user_school_1.email)
        expect(inactive_user_school_1.reload.account_deletion_notification_sent_at).to_not eq(nil)
        expect(current_email.body).to include('https://school1.host/users/sign_in')

        open_email(active_user_school_1.email)
        expect(current_email).to eq(nil)

        open_email(notified_user_school_1.email)
        expect(current_email.body).to include("Your account in #{school_1.name} has been successfully deleted")

        open_email(reactivated_user_school_1.email)
        expect(current_email).to eq(nil)

        # School 2 users wouldn't be notified as the configuration is not set
        open_email(active_user_school_2.email)
        expect(current_email).to eq(nil)

        open_email(inactive_user_school_2.email)
        expect(current_email).to eq(nil)
        expect(inactive_user_school_2.account_deletion_notification_sent_at).to eq(nil)

        # Check only notified inactive user is deleted
        expect(school_1.users.reload.find_by(id: notified_user_school_1.id)).to eq(nil)
        expect(school_1.users.count).to eq(3)
        expect(school_2.users.count).to eq(2)
      end
    end

    context 'inactivity configuration for user deletion is present in environment' do
      let!(:inactive_user_2_school_2) { create :user, school: school_2, last_sign_in_at: 160.days.ago }
      let!(:notified_user_school_2) { create :user, school: school_2, last_sign_in_at: 6.months.ago, account_deletion_notification_sent_at: 32.days.ago }

      around do |example|
        original_value = Rails.application.secrets.delete_inactive_users_after
        Rails.application.secrets.delete_inactive_users_after = 5

        example.run

        Rails.application.secrets.delete_inactive_users_after = original_value
      end

      it 'uses configuration in the environment to address inactivity if school has no configuration set' do
        subject.execute

        # Check emails of users in school_2
        open_email(inactive_user_2_school_2.email)
        expect(current_email.body).to include('https://school2.host/users/sign_in')
        expect(inactive_user_2_school_2.reload.account_deletion_notification_sent_at).to_not eq(nil)

        # Should consider only configuration in the environment for notification
        open_email(inactive_user_school_2.email)
        expect(current_email).to eq(nil)

        open_email(notified_user_school_2.email)
        expect(current_email.body).to include("Your account in #{school_2.name} has been successfully deleted")

        # Check only notified inactive user is deleted
        expect(school_1.users.reload.find_by(id: notified_user_school_2.id)).to eq(nil)
        expect(school_1.users.count).to eq(3)
        expect(school_2.users.count).to eq(3)
      end
    end
  end
end
