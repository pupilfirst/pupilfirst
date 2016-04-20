require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Incubation' do
  let(:batch) { create :batch }
  let(:startup_token) { Time.now.to_s }
  let(:team_lead) { Founder.invite!(email: 'newteamlead@example.com', invited_batch: batch, startup_admin: true, startup_token: startup_token) }
  let!(:cofounder_1) { Founder.invite!(email: 'cofounder_1@example.com', invited_batch: batch, startup_token: startup_token) }
  let!(:cofounder_2) { Founder.invite!(email: 'cofounder_2@example.com', invited_batch: batch, startup_token: startup_token) }
  let!(:university) { create :university }
  let(:startup) { create :startup }
  let!(:tet_joined) { create :tet_joined }
  let(:faculty) { create :faculty }
  let!(:read_playbook) { create :target_template, populate_on_start: true, assigner: faculty, title: 'Read Playbook', role: Target::ROLE_FOUNDER }
  let!(:pick_product_idea) { create :target_template, populate_on_start: true, assigner: faculty, title: 'Pick Product Idea', role: 'product' }

  before :all do
    WebMock.allow_net_connect!
  end

  before :each do
    # Block all RestClient POST-s.
    allow(RestClient).to receive(:post)
  end

  after :all do
    WebMock.disable_net_connect!
  end

  context 'when cofounder arrives at accept invitation path' do
    before do
      # Visit the accept invitation page.
      visit accept_founder_invitation_path(invitation_token: cofounder_1.raw_invitation_token)
    end

    scenario 'founder submits empty registration form' do
      # Make sure we are on the registration page.
      expect(page).to have_text('Set Name and Password')

      click_on 'Sign Me Up!'
      expect(page).to have_text('Please review the problems below')
    end

    scenario 'founder submits a valid and complete registration form', js: true do
      fill_in 'First name', with: 'Nemo'
      fill_in 'Last name', with: 'Nobody'
      fill_in 'New password', with: 'password'
      fill_in 'Confirm new password', with: 'password'
      choose 'Male'
      fill_in 'Date of birth', with: '01/01/1990'

      # Roll number field should be hidden by default
      expect(page).to_not have_text('University Roll Number')

      select university.name, from: 'University'

      # Roll number field should be visible on selecting a university
      expect(page).to have_text('University Roll Number')

      fill_in 'University Roll Number', with: '12345'
      fill_in 'Mobile Number', with: '9876543210'

      click_on 'Sign Me Up!'

      # founder should be at phone number verification page.
      expect(page).to have_text('Verification Code Sent!')

      # Let's check whether founder entry has been updated.
      cofounder_1.reload
      expect(cofounder_1.first_name).to eq('Nemo')
    end

    context 'when founder has registered successfully' do
      before do
        fill_in 'First name', with: 'Nemo'
        fill_in 'Last name', with: 'Nobody'
        fill_in 'New password', with: 'password'
        fill_in 'Confirm new password', with: 'password'
        choose 'Male'
        fill_in 'Date of birth', with: '01/01/1990'
        select 'Not a student', from: 'University'
        fill_in 'Mobile Number', with: '9876543210'

        click_on 'Sign Me Up!'
      end

      scenario 'founder enters wrong code' do
        fill_in 'Verification code', with: '000'
        click_on 'Verify'
        expect(page).to have_text('Verification Code Doesn’t Match!')
      end

      scenario 'founder tries an immediate resend of the code' do
        click_on 'Resend verification code'
        expect(page).to have_text('Please Wait!')
      end

      scenario 'founder requests resend after more than 5 mins' do
        expect(page).to have_text('Verification code')

        # Tweak timing a bit to allow resending of code.
        cofounder_1.reload
        old_code = cofounder_1.phone_verification_code
        cofounder_1.update!(verification_code_sent_at: 10.minute.ago)

        click_on 'Resend verification code'
        expect(page).to have_text('New Verification Code Sent!')

        # Verify that a new code was generated.
        cofounder_1.reload
        expect(cofounder_1.phone_verification_code).to_not eq(old_code)
      end

      scenario 'founder enters the right code' do
        within '#phone-verification-form' do
          cofounder_1.reload
          fill_in 'Verification code', with: cofounder_1.phone_verification_code
          click_on 'Verify'
        end

        expect(page).to have_text('Please wait for your team lead to complete registration')
      end
    end
  end

  context 'when team lead has completed founder registration' do
    before do
      # Visit the accept invitation page.
      visit accept_founder_invitation_path(invitation_token: team_lead.raw_invitation_token)

      fill_in 'First name', with: 'Nemo'
      fill_in 'Last name', with: 'Nobody'
      fill_in 'New password', with: 'password'
      fill_in 'Confirm new password', with: 'password'
      choose 'Male'
      fill_in 'Date of birth', with: '01/01/1990'
      select 'Not a student', from: 'University'
      fill_in 'Mobile Number', with: '9876543211'

      click_on 'Sign Me Up!'

      within '#phone-verification-form' do
        team_lead.reload
        fill_in 'Verification code', with: team_lead.phone_verification_code
        click_on 'Verify'
      end
    end

    scenario 'team-lead submits an empty startup registration form' do
      click_on 'Submit Application'
      expect(page).to have_text('Please review the problems below')
    end

    scenario 'team-lead submits a valid startup form with 2 co-founders' do
      fill_in 'Team Name', with: 'Team Alpha'
      click_on 'Submit Application'

      # should have reached the newly created startup's page
      expect(page).to have_text('Team Alpha')
      team_lead.reload
      cofounder_1.reload
      cofounder_2.reload

      # all founders should be part of the new startup
      expect(team_lead.startup.product_name).to eq('Team Alpha')
      expect(cofounder_1.startup).to eq(team_lead.startup)
      expect(cofounder_2.startup).to eq(team_lead.startup)

      # the new startup must be automatically approved
      expect(team_lead.startup.approved?).to be(true)

      # the timeline must be prepopulated with a single verified 'Joined SV.CO' entry
      expect(team_lead.startup.timeline_events.count).to eq(1)
      expect(team_lead.startup.timeline_events.first.timeline_event_type.key).to eq('joined_svco')
      expect(page).to have_text('Joined SV.CO')

      # the new startup must be assigned to the invited_batch of founder
      expect(team_lead.startup.batch).to eq(team_lead.invited_batch)

      # Check for presence of prepopulated timeline events.
      expect(team_lead.startup.timeline_events.count).to eq(1)
      expect(team_lead.startup.timeline_events.first.timeline_event_type).to eq(tet_joined)

      # Check for presence of prepopulated targets.
      expect(team_lead.targets.count).to eq(1)
      expect(team_lead.startup.targets.count).to eq(1)
      expect(team_lead.targets.first.title).to eq('Read Playbook')
      expect(team_lead.startup.targets.first.title).to eq('Pick Product Idea')
    end
  end
end
