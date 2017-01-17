require 'rails_helper'

feature 'Batch Application Registration' do
  # Things that are assumed to exist.
  let(:batch) { create :batch }
  let!(:application_round) { create :application_round, :in_stage_1, batch: batch }

  include UserSpecHelper

  scenario 'user submits application', js: true do
    visit apply_path
    expect(page).to have_text('Did you complete registration once before?')

    # user fills the form and submits
    fill_in 'batch_applications_registration_name', with: 'Jack Sparrow'
    fill_in 'batch_applications_registration_email', with: 'elcapitan@sv.co'
    fill_in 'batch_applications_registration_email_confirmation', with: 'elcapitan@sv.co'
    fill_in 'batch_applications_registration_phone', with: '9876543210'

    # Fill in college name because we don't want to bother with dynamically loaded select2.
    select "My college isn't listed", from: 'batch_applications_registration_college_id'
    fill_in 'batch_applications_registration_college_text', with: 'Swash Bucklers Training Institute'

    click_on 'Submit my application'

    expect(page).to have_text('Screening')
  end
end
