require 'rails_helper'

RSpec.describe Batch, type: :model do
  subject { create :batch }

  context 'when application stage changes' do
    let!(:first_stage) { create :application_stage, name: 'First Stage', number: 1 }
    let!(:second_stage) { create :application_stage, name: 'Second Stage', number: 2 }
    let!(:third_stage) { create :application_stage, name: 'Third Stage', number: 3 }
    let!(:final_stage) { create :application_stage, name: 'Last Stage', number: 4, final_stage: true }

    context 'when application is set to initial stage' do
      it 'does nothing' do
        expect(EmailApplicantsJob).to_not receive(:new)

        subject.update!(
          application_stage: first_stage,
          application_stage_deadline: Time.now
        )
      end
    end

    context 'when application is set to final stage' do
      it 'does nothing' do
        expect(EmailApplicantsJob).to_not receive(:new)

        subject.update!(
          application_stage: final_stage,
          application_stage_deadline: Time.now
        )
      end
    end

    context 'when application is set to any intermediary stage' do
      before do
        # This application's lead should not receive any mail.
        create :batch_application, batch: subject, application_stage: second_stage

        # This application's lead should receive a mail.
        create :batch_application, batch: subject, application_stage: third_stage
      end

      it 'send emails' do
        expect do
          subject.update!(
            application_stage: third_stage,
            application_stage_deadline: Time.now
          )
        end.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
