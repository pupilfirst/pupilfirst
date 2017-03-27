require 'rails_helper'

feature 'Batch Application Payment' do
  # Things that are assumed to exist.
  let(:batch) { create :batch }
  let!(:application_round) { create :application_round, :screening_stage, batch: batch }
  let(:screening_stage) { create :application_stage, number: 1 }
  let!(:batch_application) { create :batch_application, application_round: application_round, application_stage: screening_stage }
  let(:batch_applicant) { batch_application.team_lead }

  include_context 'mocked_instamojo'
  include UserSpecHelper

  scenario 'applicant goes through screening', js: true do
    sign_in_user(batch_applicant.user)
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

    expect(page).to have_content('Registration Fee')
  end
end
