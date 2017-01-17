require 'rails_helper'

feature 'Applying to SV.CO' do
  # Things that are assumed to exist.
  let!(:application_stage_1) { create :application_stage, number: 1 }
  let!(:application_stage_2) { create :application_stage, number: 2 }
  let!(:application_stage_3) { create :application_stage, number: 3 }
  let!(:college) { create :college }

  include_context 'mocked_instamojo'
  include UserSpecHelper

  context 'when a batch has moved to stage 2 - coding and video' do
    let(:batch) { create :batch }
    let!(:batch_applicant) { batch_application.team_lead }
    let!(:batch_application) do
      create :batch_application,
        batch: batch,
        application_stage: ApplicationStage.initial_stage,
        college: college,
        team_size: 2
    end

    let!(:batch_stage_1) { create :batch_stage, batch: batch, application_stage: application_stage_1 }
    let!(:batch_stage_2) { create :batch_stage, batch: batch, application_stage: application_stage_2 }
    let!(:batch_stage_3) { create :batch_stage, batch: batch, application_stage: application_stage_3, starts_at: 16.days.from_now, ends_at: 46.days.from_now }

    before do
      # add the applicant to the application
      batch_application.batch_applicants << batch_applicant

      # create a completed payment
      payment = create :payment,
        batch_application: batch_application,
        batch_applicant: batch_application.team_lead,
        instamojo_payment_request_status: 'Completed',
        instamojo_payment_status: 'Credit',
        paid_at: Time.now

      payment.batch_application.perform_post_payment_tasks!
    end

    scenario 'applicant adds cofounder details', js: true do
      # user signs in
      sign_in_user(batch_applicant.user, referer: apply_continue_path)

      # TODO: Replace this with click_link when PhantomJS moves to next version. It currently doesn't render flexbox correctly:
      # See: https://github.com/ariya/phantomjs/issues/14365
      find_link('Add cofounder details').trigger('click')

      # The page should ask for details of one co-founder.
      expect(page).to have_selector('.cofounder.content-box', count: 1)

      # Add another, and fill in details for two.
      name = Faker::Name.name
      fill_in 'Name', with: name
      fill_in 'Email address', with: Faker::Internet.email(name)

      click_button 'Add cofounder'

      expect(page).to have_selector('.cofounder.content-box', count: 2)

      within all('.cofounder.content-box').last do
        name = Faker::Name.name
        fill_in 'Name', with: name
        fill_in 'Email address', with: Faker::Internet.email(name)
      end

      click_button 'Save cofounders'

      expect(page).to have_content(/edit cofounder details/i)

      # Ensure that the cofounders have been stored.
      expect(batch_application.cofounders.count).to eq(2)
    end
  end
end
