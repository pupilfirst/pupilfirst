require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Incubation' do
  let(:user) { create :founder_with_out_password }
  let(:co_founder1) { create :founder_with_out_password }
  let(:co_founder2) { create :founder_with_out_password }
  let!(:university) { create :university }
  let(:startup) { create :startup }
  let!(:tet_joined) { create :tet_joined }

  before :all do
    WebMock.allow_net_connect!
  end

  before :each do
    # invite the user
    user.invite!

    # Block all RestClient POST-s.
    allow(RestClient).to receive(:post)
  end

  after :all do
    WebMock.disable_net_connect!
  end

  context 'when user arrives at accept invitation path' do
    before do
      # Visit the accept invitation page.
      visit accept_user_invitation_path(invitation_token: user.raw_invitation_token)
    end

    scenario 'User submits empty registration form' do
      # Make sure we are on the registration page.
      expect(page).to have_text('Set Name and Password')

      click_on 'Sign Me Up!'
      expect(page).to have_text('Please review the problems below')
    end

    scenario 'User submits a valid and complete registration form', js: true do
      fill_in 'First name', with: 'Nemo'
      fill_in 'Last name', with: user.last_name
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

      # User should be at phone number verification page.
      expect(page).to have_text('Verification Code Sent!')

      # Let's check whether user entry has been updated.
      user.reload
      expect(user.first_name).to eq('Nemo')
    end

    context 'when user has registered successfully' do
      before do
        fill_in 'First name', with: 'Nemo'
        fill_in 'Last name', with: user.last_name
        fill_in 'New password', with: 'password'
        fill_in 'Confirm new password', with: 'password'
        choose 'Male'
        fill_in 'Date of birth', with: '01/01/1990'
        select 'Not a student', from: 'University'
        fill_in 'Mobile Number', with: '9876543210'

        click_on 'Sign Me Up!'
      end

      scenario 'User enters wrong code' do
        fill_in 'Verification code', with: '000'
        click_on 'Verify'
        expect(page).to have_text('Verification Code Doesn’t Match!')
      end

      scenario 'User tries an immediate resend of the code' do
        click_on 'Resend verification code'
        expect(page).to have_text('Please Wait!')
      end

      scenario 'User requests resend after more than 5 mins' do
        # Tweak timing a bit to allow resending of code.
        old_code = user.phone_verification_code
        user.update(verification_code_sent_at: 10.minute.ago)

        click_on 'Resend verification code'
        expect(page).to have_text('New Verification Code Sent!')

        # Verify that a new code was generated.
        user.reload
        expect(user.phone_verification_code).to_not eq(old_code)
      end

      scenario 'User enters the right code' do
        within '#phone-verification-form' do
          user.reload
          fill_in 'Verification code', with: user.phone_verification_code
          click_on 'Verify'
        end

        expect(page).to have_text('Startup Creation!')
      end

      context 'when user has successfully verified phone number' do
        before do
          within '#phone-verification-form' do
            user.reload
            fill_in 'Verification code', with: user.phone_verification_code
            click_on 'Verify'
          end
        end

        scenario "Non-team-lead follows the 'complete founder profile' link" do
          click_on 'Complete your Founder Profile'
          expect(page).to have_text("Editing #{user.fullname}'s profile")
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

            expect(page).to have_text('not a registered user') # as email 1 is random
            expect(page).to have_text('can\'t be blank') # as email 2 is blank
          end

          scenario 'team-lead submits his own email as a cofounder email' do
            fill_in 'Team Name', with: 'Team Alpha'
            fill_in 'Co-founder 1', with: user.email
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
            expect(page).to have_text('by Team Alpha')
            user.reload
            co_founder1.reload
            co_founder2.reload

            # all founders should be part of the new startup
            expect(user.startup.name).to eq('Team Alpha')
            expect(co_founder1.startup).to eq(user.startup)
            expect(co_founder2.startup).to eq(user.startup)

            # the new startup must be automatically approved
            expect(user.startup.approved?).to be(true)

            # the timeline must be prepopulated with a single verified 'Joined SV.CO' entry
            expect(user.startup.timeline_events.count).to eq(1)
            expect(user.startup.timeline_events.first.timeline_event_type.key).to eq('joined_svco')
            expect(page).to have_text('Joined SV.CO')
          end
        end
      end
    end
  end
end
