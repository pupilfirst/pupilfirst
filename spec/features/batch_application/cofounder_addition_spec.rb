require 'rails_helper'

# Happy path of cofounder addition is tested in applying_to_sv_co_spec.rb
feature 'Cofounder addition' do
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

  context 'when application has been swept from one batch to another' do
    let(:older_batch) { create :batch, :in_stage_3 }
    let(:team_lead) { create :batch_applicant }
    let!(:old_application) { create :batch_application, :stage_2_submitted, team_lead: team_lead, team_size: 2, batch: older_batch }
    let!(:batch_application) { create :batch_application, :paid, batch: batch, team_lead: team_lead, team_size: 2 }

    it 'allows re-addition of cofounders' do
      sign_in_batch_applicant(batch_application.team_lead)
      visit apply_cofounders_path

      cofounder = old_application.cofounders.first

      fill_in 'Name', with: cofounder.name
      fill_in 'Email address', with: cofounder.email

      click_button 'Save cofounders'

      expect(page).to have_content(/edit cofounder details/i)

      # Ensure that the cofounders have been stored.
      expect(batch_application.reload.cofounders.count).to eq(1)
    end
  end
end
