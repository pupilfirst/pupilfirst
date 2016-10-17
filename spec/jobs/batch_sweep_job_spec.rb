require 'rails_helper'

describe BatchSweepJob do
  subject { described_class }

  let(:old_batch) { create :batch, :in_stage_3 }
  let(:new_batch) { create :batch, :in_stage_1 }
  let(:stage_1) { create(:application_stage, number: 1) }
  let(:stage_2) { create(:application_stage, number: 2) }
  let(:stage_3) { create(:application_stage, number: 3) }

  include_context 'mocked_instamojo'

  before do
    10.times do
      # expired applications in stage 1
      create :batch_application, batch: old_batch, application_stage: stage_1
    end

    5.times do
      # ongoing applications in stage 3
      create :batch_application, :paid, batch: old_batch, application_stage: stage_3
    end

    2.times do
      # expired applications in stage 2
      create :batch_application, :paid, batch: old_batch, application_stage: stage_2
    end

    2.times do
      # rejected applications in stage 2
      create :batch_application, :stage_2_submitted, batch: old_batch, application_stage: stage_2
    end
  end

  context 'when tasked with sweeping unpaid applications' do
    it 'sweeps those applications and sets swept_in_at' do
      subject.perform_now(new_batch.id, true, [], 'someone@sv.co')
      applications_in_new_batch = BatchApplication.where(batch: new_batch)
      expect(applications_in_new_batch.count).to eq(10)
      expect(applications_in_new_batch.where.not(swept_in_at: nil).count).to eq(10)
    end
  end

  context 'when asked to sweep paid rejected and expired applications' do
    it 'sweeps those applications and sets swept_in_at' do
      subject.perform_now(new_batch.id, false, [old_batch.id], 'someone@sv.co')
      applications_in_new_batch = BatchApplication.where(batch: new_batch)

      expect(applications_in_new_batch.count).to eq(4)

      # All of them will be unpaid applications
      expect(applications_in_new_batch.payment_complete.count).to eq(0)

      # All of them will be in stage 1.
      expect(applications_in_new_batch.pluck(:application_stage_id) - [ApplicationStage.initial_stage.id]).to be_empty

      # All of them will have swept_in_at set
      expect(applications_in_new_batch.where.not(swept_in_at: nil).count).to eq(4)
    end

    context 'when asked to skip payment' do
      it 'sweeps those payments and skips their payment stage' do
        subject.perform_now(new_batch.id, false, [old_batch.id], 'someone@sv.co', skip_payment: true)
        applications_in_new_batch = BatchApplication.where(batch: new_batch)
        expect(applications_in_new_batch.payment_complete.count).to eq(4)

        # All of them will be in stage 2.
        expect(applications_in_new_batch.pluck(:application_stage_id) - [ApplicationStage.testing_stage.id]).to be_empty

        # There should be four payments noting skip action.
        expect(Payment.where(notes: 'Payment has been skipped.').count).to eq(4)

        # All of them will have swept_in_at set
        expect(applications_in_new_batch.where.not(swept_in_at: nil).count).to eq(4)
      end
    end
  end
end
