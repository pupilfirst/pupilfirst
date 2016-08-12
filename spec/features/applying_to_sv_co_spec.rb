require 'rails_helper'

feature 'Applying to SV.CO' do
  # Things that are assumed to exist.
  let!(:batch) { create :batch }
  let!(:application_stage_1) { create :application_stage, number: 1 }
  let!(:application_stage_2) { create :application_stage, number: 2 }
  let!(:application_stage_3) { create :application_stage, number: 3 }
  let!(:application_stage_4) { create :application_stage, number: 4 }
  let!(:application_stage_5) { create :application_stage, number: 5 }
  let!(:other_university) { create :university, name: 'Other' }

  context 'when no batches are open' do
    scenario 'user visits apply page' do
      pending
      visit apply_path
      expect(page).to_not have_text('Did you complete registration once before?')
    end
  end

  context 'when a batch is open for applications' do
    let!(:batch) do
      create :batch,
        application_stage: application_stage_1,
        application_stage_deadline: 15.days.from_now,
        next_stage_starts_on: 1.month.from_now,
        batch_stages_attributes: [
          {
            application_stage_id: application_stage_1.id,
            starts_at: 15.days.ago,
            ends_at: 15.days.from_now
          }
        ]
    end

    scenario 'user visits apply page' do
      visit apply_path
      expect(page).to have_text('Did you complete registration once before?')
    end
  end
end
