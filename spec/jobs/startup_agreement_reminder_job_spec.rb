require 'rails_helper'

RSpec.describe StartupAgreementReminderJob, :type => :job do
  describe '.perform' do
    context 'when startup expires in 1 month' do
      let!(:startup) { create :startup, agreement_first_signed_at: 1.year.ago, agreement_last_signed_at: 1.year.ago, agreement_ends_at: 30.days.from_now }

      it 'sends expiry notification with days to renew' do
        StartupAgreementReminderJob.perform_now

        last_mail_subject = ActionMailer::Base.deliveries.last.subject
        last_mail_body = ActionMailer::Base.deliveries.last.body

        expect(last_mail_subject).to eq 'Reminder to renew your incubation agreement with Startup Village'
        expect(last_mail_body).to include 'expires in 30 days'
        expect(last_mail_body).to include 'within 15 days'
      end
    end

    context 'when startup expires in 20 days' do
      let!(:startup) { create :startup, agreement_first_signed_at: 1.year.ago, agreement_last_signed_at: 1.year.ago, agreement_ends_at: 20.days.from_now }

      it 'sends expiry notification with days to renew' do
        StartupAgreementReminderJob.perform_now

        last_mail_subject = ActionMailer::Base.deliveries.last.subject
        last_mail_body = ActionMailer::Base.deliveries.last.body

        expect(last_mail_subject).to eq 'Reminder to renew your incubation agreement with Startup Village'
        expect(last_mail_body).to include 'expires in 20 days'
        expect(last_mail_body).to include 'within 5 days'
      end
    end
  end
end
