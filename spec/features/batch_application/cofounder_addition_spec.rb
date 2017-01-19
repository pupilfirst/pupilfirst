require 'rails_helper'

# Happy path of cofounder addition is tested in applying_to_sv_co_spec.rb
feature 'Cofounder addition' do
  include UserSpecHelper

  let(:application_round) { create :application_round, :in_stage_1 }
  let(:batch_applicant) { batch_application.team_lead }
  let(:batch_application) { create :batch_application, application_round: application_round }
  let(:stage_3) { create :application_stage, number: 3 }

  context 'when editing cofounders after having payment skipped manually', js: true do
    it 'displays one editable cofounder' do
      # Manually move the application to coding stage.
      batch_application.update!(application_stage: stage_3)

      # User signs in
      sign_in_user(batch_applicant.user, referer: apply_cofounders_path)

      expect(page).to have_selector('.cofounder.content-box', count: 1)
    end
  end

  context 'when application has been swept from one batch to another' do
    let(:older_round) { create :application_round, :in_stage_4 }
    let(:team_lead) { create :batch_applicant, :with_user }
    let!(:old_application) { create :batch_application, :video_stage_submitted, team_lead: team_lead, team_size: 2, application_round: older_round }
    let!(:batch_application) { create :batch_application, :paid, application_round: application_round, team_lead: team_lead, team_size: 2 }

    it 'allows re-addition of cofounders', js: true do
      # User signs in
      sign_in_user(team_lead.user, referer: apply_cofounders_path)

      cofounder = old_application.cofounders.first

      fill_in 'Name', with: cofounder.name
      fill_in 'Email address', with: cofounder.email
      fill_in 'Mobile phone number', with: cofounder.phone
      select "My college isn't listed", from: 'College'
      fill_in 'Name of your college', with: cofounder.college.name

      click_button 'Save cofounders'

      expect(page).to have_content(/edit cofounder details/i)

      # Ensure that the cofounders have been stored.
      expect(batch_application.reload.cofounders.count).to eq(1)
    end
  end
end
