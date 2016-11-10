require 'rails_helper'

feature 'Manual payment stage skip' do
  include BatchApplicantSpecHelper

  let(:batch) { create :batch, :in_stage_2 }
  let(:batch_application) { create :batch_application, batch: batch }
  let(:stage_2) { create :application_stage, number: 2 }

  context 'when editing cofounders after having payment skipped manually' do
    it 'displays one editable cofounder' do
      # Manually move the application to stage 2.
      batch_application.update!(application_stage: stage_2)
      sign_in_batch_applicant(batch_application.team_lead)
      visit apply_cofounders_path
      expect(page).to have_selector('.cofounder.content-box', count: 1)
    end
  end
end
