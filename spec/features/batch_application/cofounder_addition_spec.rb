require 'rails_helper'

# Happy path of cofounder addition is tested in applying_to_sv_co_spec.rb
feature 'Cofounder addition', disabled: true do
  include UserSpecHelper

  let(:application_round) { create :application_round, :screening_stage }
  let(:batch_application) { create :batch_application, :paid, team_size: 2, application_round: application_round }
  let(:batch_applicant) { batch_application.team_lead }

  scenario 'applicant adds cofounder details', js: true do
    # user signs in
    sign_in_user(batch_applicant.user, referer: apply_continue_path)

    expect(page).to have_content('Build your dream startup team now')
    click_link('Add cofounder details')

    # The page should ask for details of one co-founder.
    expect(page).to have_selector('.cofounder.content-box', count: 1)

    # Add another, and fill in details for two.
    name = Faker::Name.name
    fill_in 'Name', with: name
    fill_in 'Email address', with: Faker::Internet.email(name)
    fill_in 'Mobile phone number', with: (9_876_543_210 + rand(1000)).to_s
    select "My college isn't listed", from: 'College'
    fill_in 'Name of your college', with: Faker::Lorem.words(3).join(' ')

    # The link doesn't have an href. Hence find to click.
    page.find('.cofounders-form__add-cofounder-button').click

    expect(page).to have_selector('.cofounder.content-box', count: 2)

    within all('.cofounder.content-box').last do
      name = Faker::Name.name
      fill_in 'Name', with: name
      fill_in 'Email address', with: Faker::Internet.email(name)
      fill_in 'Mobile phone number', with: (9_876_543_210 + rand(1000)).to_s
      select "My college isn't listed", from: 'College'
      fill_in 'Name of your college', with: Faker::Lorem.words(3).join(' ')
    end

    click_button 'Save cofounders'

    expect(page).to have_content(/edit cofounder details/i)

    # Ensure that the cofounders have been stored.
    expect(batch_application.cofounders.count).to eq(2)
  end

  context 'when editing cofounders after having payment skipped manually', js: true do
    let(:batch_application) { create :batch_application, application_round: application_round }
    let(:stage_3) { create :application_stage, number: 3 }

    it 'displays one editable cofounder' do
      # Manually move the application to coding stage.
      batch_application.update!(application_stage: stage_3)

      # User signs in
      sign_in_user(batch_applicant.user, referer: apply_cofounders_path)

      expect(page).to have_selector('.cofounder.content-box', count: 1)
    end
  end

  context 'when application has been swept from one batch to another' do
    let(:older_round) { create :application_round, :video_stage }
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
