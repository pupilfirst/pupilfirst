require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Incubation' do
  let(:batch) { create :batch }
  let(:founder) { Founder.invite!(email: "newfounder@example.com", invited_batch: batch) }
  let(:co_founder1) { create :founder_with_out_password }
  let(:co_founder2) { create :founder_with_out_password }
  let!(:university) { create :university }
  let(:startup) { create :startup }
  let!(:tet_joined) { create :tet_joined }
  let(:faculty) { create :faculty }
  let!(:read_playbook) { create :target_template, populate_on_start: true, assigner: faculty, title: 'Read Playbook' }

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

  context 'when founder arrives at accept invitation path' do
    before do
      # Visit the accept invitation page.
      visit accept_founder_invitation_path(invitation_token: founder.raw_invitation_token)
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
      founder.reload
      expect(founder.first_name).to eq('Nemo')
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
        founder.reload
        old_code = founder.phone_verification_code
        founder.update!(verification_code_sent_at: 10.minute.ago)

        click_on 'Resend verification code'
        expect(page).to have_text('New Verification Code Sent!')

        # Verify that a new code was generated.
        founder.reload
        expect(founder.phone_verification_code).to_not eq(old_code)
      end

      scenario 'founder enters the right code' do
        within '#phone-verification-form' do
          founder.reload
          fill_in 'Verification code', with: founder.phone_verification_code
          click_on 'Verify'
        end

        expect(page).to have_text('Startup Creation!')
      end

      context 'when founder has successfully verified phone number' do
        before do
          within '#phone-verification-form' do
            founder.reload
            fill_in 'Verification code', with: founder.phone_verification_code
            click_on 'Verify'
          end
        end

        scenario "Non-team-lead follows the 'complete founder profile' link" do
          click_on 'Complete your Founder Profile'
          expect(page).to have_text("Editing #{founder.fullname}'s profile")
        end

        scenario 'Team-lead gives consent and heads to startup registration', js: true do
          # Should not be able to click create startup button without supplying consent.
          expect { click_on 'Create Startup!' }.to raise_error(Capybara::Webkit::ClickFailed)

          check 'team-leader-consent'
          click_on 'Create Startup!'

          expect(page).to have_text('Team Name')
        end

        context 'when team leader supplies consent to creation of startup' do
          before do
            within '.startup-creation-box' do
              check 'team-leader-consent'
              click_on 'Create Startup!'
            end
          end

          scenario 'team-lead submits an empty startup registration form' do
            click_on 'Submit Application'
            expect(page).to have_text('Please review the problems below')
          end

          scenario 'team-lead submits startup form with one invalid co-founder' do
            fill_in 'Team Name', with: 'Team Alpha'
            fill_in 'Co-founder 1', with: 'random@email.com'
            click_on 'Submit Application'

            expect(page).to have_text('could not find founder with this email') # as email 1 is random
            expect(page).to have_text('can\'t be blank') # as email 2 is blank
          end

          scenario 'team-lead submits his own email as a cofounder email' do
            fill_in 'Team Name', with: 'Team Alpha'
            fill_in 'Co-founder 1', with: founder.email
            click_on 'Submit Application'

            expect(page).to have_text('already the team lead')
          end

          scenario 'team-lead submits duplicate emails for co-founders' do
            fill_in 'Team Name', with: 'Team Alpha'
            fill_in 'Co-founder 1', with: co_founder1.email
            fill_in 'Co-founder 2', with: co_founder1.email
            click_on 'Submit Application'

            expect(page).to have_text('must be unique')
          end

          scenario 'team-lead submits a co-founder who already has a startup' do
            startup.founders << co_founder1 # assign co_founder1 to a startup

            fill_in 'Team Name', with: 'Team Alpha'
            fill_in 'Co-founder 1', with: co_founder1.email
            fill_in 'Co-founder 2', with: co_founder2.email
            click_on 'Submit Application'

            expect(page).to have_text('already has a startup')
          end

          scenario 'team-lead submits team-size as 4 without a third co-founder', js: true do
            fill_in 'Team Name', with: 'Team Alpha'

            # only two co-founder email fields should be present by default
            expect(page).not_to have_text('Co-founder 3')

            select '4', from: 'Team size'
            # a third co-founder field should now be visible
            expect(page).to have_text('Co-founder 3')

            fill_in 'Co-founder 1', with: co_founder1.email
            fill_in 'Co-founder 2', with: co_founder2.email
            click_on 'Submit Application'

            expect(page).to have_text('can\'t be blank') # as co-founder 3 is missing for team size 4
          end

          scenario 'team-lead submits a valid startup form with 2 co-founders' do
            fill_in 'Team Name', with: 'Team Alpha'
            fill_in 'Co-founder 1', with: co_founder1.email
            fill_in 'Co-founder 2', with: co_founder2.email
            click_on 'Submit Application'

            # should have reached the newly created startup's page
            expect(page).to have_text('Team Alpha')
            founder.reload
            co_founder1.reload
            co_founder2.reload

            # all founders should be part of the new startup
            expect(founder.startup.product_name).to eq('Team Alpha')
            expect(co_founder1.startup).to eq(founder.startup)
            expect(co_founder2.startup).to eq(founder.startup)

            # the new startup must be automatically approved
            expect(founder.startup.approved?).to be(true)

            # the timeline must be prepopulated with a single verified 'Joined SV.CO' entry
            expect(founder.startup.timeline_events.count).to eq(1)
            expect(founder.startup.timeline_events.first.timeline_event_type.key).to eq('joined_svco')
            expect(page).to have_text('Joined SV.CO')

            # the new startup must be assigned to the invited_batch of founder
            expect(founder.startup.batch).to eq(founder.invited_batch)

            # Check for presence of prepopulated timeline events.
            expect(founder.startup.timeline_events.count).to eq(1)
            expect(founder.startup.timeline_events.first.timeline_event_type).to eq(tet_joined)

            # Check for presence of prepopulated targets.
            expect(founder.startup.targets.count).to eq(1)
            expect(founder.startup.targets.first.title).to eq('Read Playbook')
          end
        end
      end
    end
  end
end
