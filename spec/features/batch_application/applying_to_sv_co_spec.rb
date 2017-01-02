require 'rails_helper'

feature 'Applying to SV.CO' do
  # Things that are assumed to exist.
  let!(:application_stage_1) { create :application_stage, number: 1 }
  let!(:application_stage_2) { create :application_stage, number: 2 }
  let!(:application_stage_3) { create :application_stage, number: 3 }
  let!(:college) { create :college }

  include_context 'mocked_instamojo'

  context 'when a batch is open for applications' do
    let(:batch) { create :batch }
    let!(:batch_stage_1) { create :batch_stage, batch: batch, application_stage: application_stage_1 }
    let!(:batch_stage_2) { create :batch_stage, batch: batch, application_stage: application_stage_2, starts_at: 16.days.from_now, ends_at: 46.days.from_now }

    scenario 'user submits application and pays' do
      pending 'college id picking is broken'

      visit apply_path
      expect(page).to have_text('Did you complete registration once before?')

      # user fills the form and submits
      fill_in 'batch_application_name', with: 'Jack Sparrow'
      fill_in 'batch_application_email', with: 'elcapitan@thesea.com'
      fill_in 'batch_application_email_confirmation', with: 'elcapitan@thesea.com'
      fill_in 'batch_application_phone', with: '9876543210'
      fill_in 'batch_application_college_id', with: college.id
      click_on 'Submit my application'

      # user must be at the payment page
      expect(page).to have_text('You now need to pay the registration fee')

      # user must have recieved a 'Continue Application' email
      open_email('elcapitan@thesea.com')
      expect(current_email.subject).to eq('Continue application at SV.CO')

      # prepare for invoking payment
      batch_applicant = BatchApplicant.find_by(email: 'elcapitan@thesea.com')
      batch_application = batch_applicant.batch_applications.last

      # user selects co-founder count and clicks pay
      select '2', from: 'application_stage_one_team_size_select'
      expect(page).to have_text('You need to pay Rs. 3000')
      click_on 'Pay Fees Online'

      # uses must be re-directed to the payment's long_url
      expect(page.current_url).to eq(long_url)

      payment = Payment.last
      # ensure we got the right payment
      expect(payment.batch_application).to eq(batch_application)

      # mimic payment completion
      payment.update!(
        instamojo_payment_request_status: 'Completed',
        instamojo_payment_status: 'Credit',
        paid_at: Time.now
      )
      payment.batch_application.perform_post_payment_tasks!

      # user reaches stage/1/complete
      visit apply_stage_complete_path(stage_number: '1')
      expect(page).to have_text('your payment has been accepted')
    end

    context 'when an applied user returns' do
      # ready-to-use returning applicant and his application
      let(:batch_applicant) { create :batch_applicant }

      let!(:batch_application) do
        create :batch_application,
          batch: batch,
          application_stage: ApplicationStage.initial_stage,
          college: college,
          team_lead_id: batch_applicant.id
      end

      before do
        batch_application.batch_applicants << batch_applicant
      end

      scenario 'returning applicant restarts application' do
        # user signs in
        visit apply_path
        expect(page).to have_text('Did you complete registration once before?')

        click_on 'Sign In to Continue'
        expect(page).to have_text('Please supply your email address')

        fill_in 'batch_applicant_sign_in_email', with: batch_applicant.email
        click_on 'Resend link to resume application'

        # user must be told an email was sent
        expect(page).to have_text("Please use the link that we've mailed you to resume the application process")

        # user must have recieved a 'Continue Application' email
        open_email(batch_applicant.email)
        continue_path = apply_continue_path(token: batch_applicant.token, shared_device: false)
        expect(current_email.body).to have_text(continue_path)

        # user follows login link sent
        visit continue_path

        # user must be at the payment page
        expect(page).to have_text('You now need to pay the registration fee')

        click_on 'Cancel and Restart Application'

        expect(page).to have_text('Did you complete registration once before?')

        # Applicant should be blocked from visiting inner pages, now that he doesn't have an application.
        visit apply_cofounders_path

        expect(page).to have_text("Haven't submitted an application yet?")

        visit apply_stage_path(stage_number: 1)

        expect(page).to have_text("Haven't submitted an application yet?")
      end

      context 'when applicant stage has expired' do
        let!(:batch_stage_1) { create :batch_stage, batch: batch, application_stage: application_stage_1, starts_at: 45.days.ago, ends_at: 15.days.ago }
        let!(:batch_stage_2) { create :batch_stage, batch: batch, application_stage: application_stage_2 }

        scenario 'applicant did not complete payment in time' do
          continue_path = apply_continue_path(token: batch_applicant.token, shared_device: false)
          visit continue_path

          expect(page).to have_content 'Application process has closed'
        end
      end
    end
  end

  context 'when a batch has moved to stage 2 - coding and video' do
    let(:batch) { create :batch }
    let(:batch_applicant) { create :batch_applicant }

    let!(:batch_application) do
      create :batch_application,
        batch: batch,
        application_stage: ApplicationStage.initial_stage,
        college: college,
        team_lead_id: batch_applicant.id,
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

    context 'when cofounders are absent' do
      scenario 'paid applicant fails to submit his code and video links' do
        visit apply_continue_path(token: batch_applicant.token, shared_device: false)

        # user must see the coding and video tasks
        expect(page).to have_text('Coding Task')

        # user fills the stage 2 form and submits
        fill_in 'application_stage_two_git_repo_url', with: 'https://github.com'
        select 'Website', from: 'application_stage_two_app_type'
        fill_in 'application_stage_two_website', with: 'http://example.com'
        fill_in 'application_stage_two_video_url', with: 'https://facebook.com'
        click_on 'Submit your entries'

        # user submission must be acknowledged
        expect(page).to have_text('Please add cofounders before submitting this form')
      end
    end

    context 'when cofounders are present' do
      before do
        batch_application.batch_applicants << create(:batch_applicant)
      end

      scenario 'paid applicant is able to submit code and video links' do
        visit apply_continue_path(token: batch_applicant.token, shared_device: false)

        # User must see the coding and video tasks.
        expect(page).to have_text('Coding Task')
        expect(page).to have_text('Video Task')

        # User fills the stage 2 form and submits.
        fill_in 'application_stage_two_git_repo_url', with: 'https://github.com/user/repo'
        select 'Website', from: 'application_stage_two_app_type'
        fill_in 'application_stage_two_website', with: 'example.com'
        fill_in 'application_stage_two_video_url', with: 'https://facebook.com/user/videos/random'
        click_on 'Submit your entries'

        # User submission must be acknowledged.
        expect(page).to have_text('Your coding and hustling submissions has been received')

        # Example link should have had http prepended since its missing.
        expect(page).to have_link('Live Website', href: 'http://example.com')
      end
    end

    scenario 'applicant adds cofounder details', js: true do
      visit apply_continue_path(token: batch_applicant.token, shared_device: false)

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

    context 'when applicant has submitted for stage 2' do
      let(:application_submission) do
        create :application_submission,
          application_stage: application_stage_2,
          batch_application: batch_application
      end

      before do
        create :application_submission_url, application_submission: application_submission

        create :application_submission_url,
          application_submission: application_submission,
          name: 'Facebook Video',
          url: 'https://facebook.com/video'

        create :application_submission_url,
          application_submission: application_submission,
          name: 'Code Repository',
          url: 'https://github.com/user/repo'
      end

      scenario 'applicant removes existing submission' do
        visit apply_continue_path(token: batch_applicant.token, shared_device: false)

        # user submission must be acknowledged
        expect(page).to have_text('Your coding and hustling submissions has been received')

        click_on 'Redo your submission'

        # user must see the coding and video tasks
        expect(page).to have_text('Coding Task')
        expect(page).to have_text('Video Task')
      end
    end
  end
end
