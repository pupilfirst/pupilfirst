require "rails_helper"

describe Users::InactivityNotificationAndDeletionService do
  include ActiveSupport::Testing::TimeHelpers
  include HtmlSanitizerSpecHelper

  subject { described_class.new }

  # Setup the basics
  let(:school_1) do
    create :school, configuration: { "delete_inactive_users_after" => 4 }
  end
  let!(:domain_school_1) do
    create :domain, school: school_1, primary: true, fqdn: "school1.host"
  end
  let(:school_2) { create :school }
  let!(:domain_school_2) do
    create :domain, school: school_2, primary: true, fqdn: "school2.host"
  end

  # Users in school_1
  let!(:active_user_school_1) do
    create :user, school: school_1, last_sign_in_at: 3.days.ago
  end
  let!(:inactive_user_school_1) do
    create :user, school: school_1, last_sign_in_at: 100.days.ago
  end
  let!(:notified_user_school_1) do
    create :user,
           school: school_1,
           last_sign_in_at: 5.months.ago,
           account_deletion_notification_sent_at: 32.days.ago
  end
  let!(:reactivated_user_school_1) do
    create :user,
           school: school_1,
           last_sign_in_at: 2.days.ago,
           account_deletion_notification_sent_at: 32.days.ago
  end

  # Users in school_2
  let!(:active_user_school_2) do
    create :user, school: school_2, last_sign_in_at: 3.days.ago
  end
  let!(:inactive_user_school_2) do
    create :user, school: school_2, last_sign_in_at: 100.days.ago
  end

  describe "#execute" do
    context "inactivity configuration for user deletion is absent in environment" do
      around do |example|
        original_value = Settings.delete_inactive_users_after
        Settings.delete_inactive_users_after = 0

        example.run

        Settings.delete_inactive_users_after = original_value
      end
      it "sends notification and deletes users only in school with configuration" do
        subject.execute

        # Check emails of all users
        open_email(inactive_user_school_1.email)

        expect(
          inactive_user_school_1.reload.account_deletion_notification_sent_at
        ).to_not eq(nil)

        expect(current_email.subject).to eq(
          "Your account in #{school_1.name} will be deleted in 30 days"
        )

        expect(sanitize_html(current_email.body)).to include(
          "https://school1.host/users/sign_in"
        )

        open_email(active_user_school_1.email)
        expect(current_email).to eq(nil)

        open_email(notified_user_school_1.email)
        expect(sanitize_html(current_email.body)).to include(
          "Your account in #{school_1.name} has been successfully deleted"
        )

        open_email(reactivated_user_school_1.email)
        expect(current_email).to eq(nil)

        # School 2 users wouldn't be notified as the configuration is not set
        open_email(active_user_school_2.email)
        expect(current_email).to eq(nil)

        open_email(inactive_user_school_2.email)
        expect(current_email).to eq(nil)
        expect(
          inactive_user_school_2.account_deletion_notification_sent_at
        ).to eq(nil)

        # Check only notified inactive user is deleted
        expect(
          school_1.users.reload.find_by(id: notified_user_school_1.id)
        ).to eq(nil)
        expect(school_1.users.count).to eq(3)
        expect(school_2.users.count).to eq(2)

        # Check audit record is created
        audit_record = AuditRecord.last
        expect(audit_record.audit_type).to eq(
          AuditRecord.audit_types[:delete_account]
        )
        expect(audit_record.metadata["email"]).to eq(
          notified_user_school_1.email
        )
        expect(
          audit_record.metadata["account_deletion_notification_sent_at"]
        ).to eq(
          notified_user_school_1.account_deletion_notification_sent_at.iso8601
        )
      end
    end

    context "inactivity configuration for user deletion is present in environment" do
      let!(:inactive_user_2_school_2) do
        create :user, school: school_2, last_sign_in_at: 160.days.ago
      end
      let!(:notified_user_school_2) do
        create :user,
               school: school_2,
               last_sign_in_at: 6.months.ago,
               account_deletion_notification_sent_at: 32.days.ago
      end

      around do |example|
        original_value = Settings.delete_inactive_users_after
        Settings.delete_inactive_users_after = 5

        example.run

        Settings.delete_inactive_users_after = original_value
      end

      it "uses configuration in the environment to address inactivity if school has no configuration set" do
        subject.execute

        # Check emails of users in school_2
        open_email(inactive_user_2_school_2.email)
        expect(sanitize_html(current_email.body)).to include(
          "https://school2.host/users/sign_in"
        )
        expect(
          inactive_user_2_school_2.reload.account_deletion_notification_sent_at
        ).to_not eq(nil)

        # Should consider only configuration in the environment for notification
        open_email(inactive_user_school_2.email)
        expect(current_email).to eq(nil)

        open_email(notified_user_school_2.email)
        expect(sanitize_html(current_email.body)).to include(
          "Your account in #{school_2.name} has been successfully deleted"
        )

        # Check only notified inactive user is deleted
        expect(
          school_1.users.reload.find_by(id: notified_user_school_2.id)
        ).to eq(nil)
        expect(school_1.users.count).to eq(3)
        expect(school_2.users.count).to eq(3)
      end
    end
  end
end
