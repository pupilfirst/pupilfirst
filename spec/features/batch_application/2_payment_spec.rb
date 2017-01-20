require 'rails_helper'

feature 'Batch Application Payment' do
  # Things that are assumed to exist.
  let(:batch) { create :batch }
  let!(:application_round) { create :application_round, :screening_stage, batch: batch }
  let(:payment_stage) { create :application_stage, number: 2 }
  let!(:batch_application) { create :batch_application, application_round: application_round, application_stage: payment_stage }
  let(:batch_applicant) { batch_application.team_lead }

  include_context 'mocked_instamojo'
  include UserSpecHelper

  scenario 'applicant pays for application', js: true do
    sign_in_user(batch_applicant.user)
    expect(page).to have_text('You now need to pay the registration fee')

    # User selects co-founder count and clicks pay.
    select '2', from: 'batch_applications_payment_team_size'
    expect(page).to have_text('You need to pay Rs. 1000')
    click_on 'Pay Fees Online'

    # User must be re-directed to the payment's long_url.
    expect(page.current_url).to eq(long_url)

    payment = Payment.last
    # ensure we got the right payment
    expect(payment.batch_application).to eq(batch_application)

    # Mimic payment completion.
    payment.update!(
      instamojo_payment_request_status: 'Completed',
      instamojo_payment_status: 'Credit',
      paid_at: Time.now
    )
    payment.batch_application.perform_post_payment_tasks!

    # User reaches coding stage.
    visit apply_continue_path
    expect(page).to have_text('Before getting started with the coding task, please consider adding some details about your cofounders.')
  end

  scenario 'returning applicant restarts application' do
    sign_in_user(batch_applicant.user, referer: apply_path)
    expect(page).to have_text('You have already completed registration')
    click_on 'Continue application'

    # User must be at the payment page.
    expect(page).to have_text('You now need to pay the registration fee')

    # User clicks on the 'Cancel and Restart Application' button, returns to the apply page and remains signed in.
    click_on 'Cancel and Restart Application'

    expect(page).to have_content('Unique Admission Process to show team skills')
    expect(page).to have_no_button('Continue application')
    expect(page).to have_no_button('Sign In to Continue')
  end

  context 'when payment stage has expired' do
    before do
      initial_stages = application_round.round_stages.where(application_stage: ApplicationStage.where(number: [1, 2, 3]))
      initial_stages.update_all(starts_at: 45.days.ago, ends_at: 15.days.ago)
    end

    scenario 'applicant did not complete payment in time' do
      sign_in_user(batch_applicant.user, referer: apply_continue_path)
      expect(page).to have_content 'Application process has closed'
    end
  end
end
