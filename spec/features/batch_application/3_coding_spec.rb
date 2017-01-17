require 'rails_helper'

feature 'Batch Application Coding Stage' do
  # Things that are assumed to exist.
  let(:batch) { create :batch }
  let!(:application_round) { create :application_round, :in_stage_1, batch: batch }
  let(:payment_stage) { create :application_stage, number: 2 }

  # Note that application is created in stage 2, but will be upgraded to stage 2 by code in before block.
  let(:batch_application) { create :batch_application, application_round: application_round, application_stage: payment_stage }
  let(:batch_applicant) { batch_application.team_lead }

  before do
    # This will create the payment and also upgrade the application to stage 3.
    create :payment, :paid, batch_application: batch_application
  end

  include UserSpecHelper

  scenario 'applicant submits coding task', js: true do
    # user signs in
    sign_in_user(batch_applicant.user, referer: apply_continue_path)

    # User must see the coding tasks.
    expect(page).to have_text('Coding Task')

    # User fills the coding stage form and submits.
    select 'Coding Task', from: 'batch_applications_coding_stage_submission_type'
    fill_in 'batch_applications_coding_stage_git_repo_url', with: 'https://github.com/user/repo'
    select 'Website', from: 'batch_applications_coding_stage_app_type'
    fill_in 'batch_applications_coding_stage_website', with: 'example.com'
    click_on 'Submit your entry'

    # User submission must be acknowledged.
    expect(page).to have_text('Your coding submission has been received')

    # Example link should have had http prepended since its missing.
    expect(page).to have_link('Live Website', href: 'http://example.com')

    expect(batch_application.reload.generate_certificate).to eq(true)
  end

  scenario 'applicant submits previous work', js: true do
    # user signs in
    sign_in_user(batch_applicant.user, referer: apply_continue_path)

    # User must see the coding tasks.
    expect(page).to have_text('Coding Task')

    # User fills the coding stage form and submits.
    select 'Previous Work', from: 'batch_applications_coding_stage_submission_type'
    fill_in 'batch_applications_coding_stage_git_repo_url', with: 'https://github.com/user/repo'
    select 'Application', from: 'batch_applications_coding_stage_app_type'
    fill_in 'batch_applications_coding_stage_executable', with: 'dropbox.com/link/to/executable'
    click_on 'Submit your entry'

    # User submission must be acknowledged.
    expect(page).to have_text('Your coding submission has been received')

    # Example link should have had http prepended since its missing.
    expect(page).to have_link('Application Binary', href: 'http://dropbox.com/link/to/executable')

    expect(batch_application.reload.generate_certificate).to eq(false)
  end

  context 'when applicant has submitted for coding stage' do
    let(:application_submission) do
      create :application_submission,
        application_stage: ApplicationStage.coding_stage,
        batch_application: batch_application,
        notes: 'Coding Submission'
    end

    before do
      batch_application.update!(generate_certificate: true)

      create :application_submission_url, application_submission: application_submission

      create :application_submission_url,
        application_submission: application_submission,
        name: 'Code Repository',
        url: 'https://github.com/user/repo'

      create :application_submission_url,
        application_submission: application_submission,
        name: 'Application Binary',
        url: 'http://dropbox.com/link/to/executable'
    end

    scenario 'applicant removes existing submission' do
      # user signs in
      sign_in_user(batch_applicant.user, referer: apply_continue_path)

      # user submission must be acknowledged
      expect(page).to have_text('Your coding submission has been received')

      click_on 'Redo your submission'

      # user must see the coding and video tasks
      expect(page).to have_text('Coding Task')

      expect(batch_application.reload.generate_certificate).to eq(false)
    end
  end
end
