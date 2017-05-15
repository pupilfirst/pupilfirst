require 'rails_helper'

feature 'Screening' do
  include UserSpecHelper

  let(:startup) { create :level_0_startup }
  let(:founder) { startup.admin }
  let(:level_0) { create :level, :zero }
  let(:level_0_targets) { create :target_group, milestone: true, level: level_0 }
  let!(:screening_target) { create :target, :admissions_screening, target_group: level_0_targets }
  let!(:fee_payment_target) { create :target, :admissions_fee_payment, target_group: level_0_targets }
  let!(:tet_team_update) { create :timeline_event_type, :team_update }

  scenario 'applicant goes through screening', js: true do
    sign_in_user(founder.user, referer: admissions_screening_path)

    expect(page).to have_text('Let’s find out if you are a right fit for our program.')

    click_button 'START', match: :first

    expect(page).to have_content('Have you contributed to Open Source?')
    page.find('label[for="answer-option-No"]').click
    find_button('Next').click
    expect(page).to have_content('a technical course at Coursera')
    page.find('label[for="answer-option-No"]').click
    find_button('Next').click
    expect(page).to have_content('Have you built websites')
    page.find('label[for="answer-option-No"]').click
    find_button('Next').click

    expect(page).to have_text('You have not cleared our basic screening process.')

    click_button 'Restart'

    page.find('.applicant-screening__cover.non-coder-cover').find('button').click

    expect(page).to have_content('Have you ever worked with a developer')
    page.find('label[for="answer-option-Yes"]').click
    find_button('Next').click
    expect(page).to have_content('Have you ever made money')
    page.find('label[for="answer-option-Yes"]').click
    find_button('Next').click
    expect(page).to have_content('Have you ever led a team')
    page.find('label[for="answer-option-Yes"]').click
    find_button('Next').click

    expect(page).to have_text('your first task is to find the coder')

    click_button 'Continue Application'

    expect(page).to have_content('Screening target has been marked as completed!')
    expect(page).to have_selector('.founder-dashboard-target-header__status-badge', text: 'Complete')

    # founder should be markes as a Hustler
    expect(founder.reload.hacker).to eq(false)
  end
end
