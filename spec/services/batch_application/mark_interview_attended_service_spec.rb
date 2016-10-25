require 'rails_helper'

describe BatchApplication::MarkInterviewAttendedService do
  subject { described_class.new(batch_application) }

  let(:batch_application) { create :batch_application, :paid }

  before do
    create :application_stage, number: 1
    create :application_stage, number: 2
    create :application_stage, number: 3
    create :application_stage, number: 4
  end

  context 'when batch application is not in interview stage' do
    it 'does nothing' do
      expect do
        subject.execute
      end.to_not change(batch_application.application_submissions, :count)
    end
  end

  context 'when batch application is in interview stage' do
    let(:batch_application) { create :batch_application, :stage_3 }

    it 'creates submission for interview stage' do
      expect do
        subject.execute
      end.to change(batch_application.application_submissions, :count)
    end

    context 'when a submission for interview stage already exists' do
      before do
        create :application_submission, batch_application: batch_application, application_stage: ApplicationStage.interview_stage
      end

      it 'does nothing' do
        expect do
          subject.execute
        end.to_not change(batch_application.application_submissions, :count)
      end
    end
  end
end
