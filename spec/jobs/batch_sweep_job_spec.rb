require 'rails_helper'

describe BatchSweepJob do
  subject { described_class }

  let(:old_round) { create :application_round, :interview_stage }
  let(:new_round) { create :application_round, :screening_stage }
  let(:payment_stage) { create(:application_stage, :payment) }
  let(:coding_stage) { create(:application_stage, :coding) }
  let(:interview_stage) { create(:application_stage, :interview) }

  include_context 'mocked_instamojo'

  before do
    10.times do
      # Expired applications in payment stage.
      create :batch_application, application_round: old_round, application_stage: payment_stage
    end

    5.times do
      # Ongoing applications in interview stage.
      create :batch_application, :interview_stage, application_round: old_round
    end

    2.times do
      # Expired applications in coding stage.
      create :batch_application, :paid, application_round: old_round
    end

    # Rejected applications in coding and video stage.
    create :batch_application, :coding_stage_submitted, application_round: old_round
    create :batch_application, :video_stage_submitted, application_round: old_round
  end

  context 'when tasked with sweeping unpaid applications' do
    it 'sweeps those applications and sets swept_in_at' do
      subject.perform_now(new_round.id, true, [], 'someone@sv.co')
      applications_in_new_round = BatchApplication.where(application_round: new_round)
      expect(applications_in_new_round.count).to eq(10)
      expect(applications_in_new_round.where.not(swept_in_at: nil).count).to eq(10)
    end
  end

  context 'when asked to sweep paid rejected and expired applications' do
    it 'sweeps those applications and sets swept_in_at' do
      subject.perform_now(new_round.id, false, [old_round.id], 'someone@sv.co')
      applications_in_new_round = BatchApplication.where(application_round: new_round)

      expect(applications_in_new_round.count).to eq(4)

      # All of them will be unpaid applications
      expect(applications_in_new_round.payment_complete.count).to eq(0)

      # All of them will be in stage 1.
      expect(applications_in_new_round.pluck(:application_stage_id) - [ApplicationStage.initial_stage.id]).to be_empty

      # All of them will have swept_in_at set
      expect(applications_in_new_round.where.not(swept_in_at: nil).count).to eq(4)
    end

    context 'when asked to skip payment' do
      it 'sweeps those payments and skips their payment stage' do
        subject.perform_now(new_round.id, false, [old_round.id], 'someone@sv.co', skip_payment: true)
        applications_in_new_round = BatchApplication.where(application_round: new_round)
        expect(applications_in_new_round.count).to eq(4)

        # All of them will be in coding stage.
        expect(applications_in_new_round.pluck(:application_stage_id) - [coding_stage.id]).to be_empty

        # Number of payments should not have changed.
        expect(Payment.count).to eq(9)

        # All of them will have swept_in_at set.
        expect(applications_in_new_round.where.not(swept_in_at: nil).count).to eq(4)
      end
    end
  end
end
