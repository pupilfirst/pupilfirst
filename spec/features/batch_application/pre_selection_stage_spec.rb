require 'rails_helper'

feature 'Pre-selection Stage' do
  include BatchApplicantSpecHelper

  let(:batch) { create :batch, :in_stage_4 }
  let(:batch_application) { create :batch_application, :stage_4, batch: batch }

  before do
    sign_in_batch_applicant(batch_application.team_lead)
  end

  context 'when pre-selection stage is ongoing' do
    scenario 'user is shown ongoing state page' do
      expect(page).to have_content('Your Startup awaits!')
      expect(page).to have_content("You have been selected to Batch #{batch.batch_number} starting #{batch.start_date.strftime('%B %d, %Y')}")
    end
  end

  context 'when pre-selection stage is over' do
    context 'when applicant has not submitted required documents' do
      scenario 'user is shown expired state page'
    end

    context 'when the applicant has attended submitted documents' do
      scenario 'user is shown submitted state page'

      context 'when the batch has progressed to next stage' do
        let(:stage_5) { create(:application_stage, number: 5) }

        before do
          BatchStage.find_by(batch: batch, application_stage: stage_4).update!(ends_at: 1.day.ago)
          create(:batch_stage, batch: batch, application_stage: stage_5, starts_at: 3.days.ago)
        end

        scenario 'user is shown rejected state page'
      end
    end
  end
end
