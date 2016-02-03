require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Incubation', focus: true do
  let(:user) { create :user_with_out_password }
  let!(:university) { create :university }

  before :all do
    WebMock.allow_net_connect!
  end

  before :each do
    # invite the user
    user.invite!

    # # Login the user.
    # visit new_user_session_path
    # fill_in 'user_email', with: user.email
    # fill_in 'user_password', with: 'password'
    # click_on 'Sign in'
    #
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

    scenario 'User submits a valid and complete registration form' do
      # TODO: This should be a js: true scenario, which tests addition of university roll number.

      fill_in 'First name', with: 'Nemo'
      fill_in 'Last name', with: user.last_name
      fill_in 'New password', with: 'password'
      fill_in 'Confirm new password', with: 'password'
      choose 'Male'
      fill_in 'Date of birth', with: '01/01/1990'
      select 'Not a student', from: 'University'
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
            check 'team-leader-consent'
            click_on 'Create Startup!'
          end

          # scenario 'something'
        end
      end
    end
  end

  # scenario 'User applies to SV.CO' do
  #   visit root_path
  #   expect(page).to have_text('Apply for Incubation!')
  #
  #   click_on 'Apply for Incubation!'
  #   expect(page).to have_text('Please supply your phone number to continue')
  #
  #   fill_in 'Your phone number', with: '9876543210'
  #   click_on 'Proceed to phone number verification'
  #   expect(page).to have_text('An SMS containing a verification code has been sent to your mobile number')
  #
  #   user.reload
  #
  #   fill_in 'Verification code', with: user.phone_verification_code
  #   click_on 'Verify'
  #   expect(page).to have_text("Yes, I'm the Team Leader.")
  #
  #   check 'team-leader-consent'
  #   click_on 'Start incubation!'
  #   expect(page).to have_text('Communication address')
  #
  #   choose 'Female'
  #   fill_in 'Date of birth', with: '03/03/1982'
  #   fill_in 'Communication address', with: "This is\nwhere I live."
  #   fill_in 'District', with: 'district_name'
  #   fill_in 'State', with: 'state_name'
  #   fill_in 'PIN Code', with: 600_001
  #   fill_in 'LinkedIn URL', with: 'https://linkedin.com/url'
  #   fill_in 'Twitter URL', with: 'https://twitter.com/url'
  #   click_on 'Next Step'
  #   expect(page).to have_text('Incubation location')
  #
  #   fill_in 'Product Name', with: 'Test product'
  #   fill_in 'About your Product', with: "About\nTest\nproduct"
  #   fill_in 'Product Deck', with: 'https://sv.co'
  #   select 'Visakhapatnam', from: 'Incubation location'
  #   fill_in 'Website', with: 'https://startupwebsite.com'
  #   select 'Partnership', from: 'Registration type'
  #   select startup_category_1.name, from: 'Startup categories'
  #   select startup_category_2.name, from: 'Startup categories'
  #   select startup_category_3.name, from: 'Startup categories'
  #   fill_in 'Team size', with: 1
  #   fill_in 'No. of women employees', with: 0
  #   click_on 'Submit Application'
  #
  #   expect(page).to have_text("That's it! You're done")
  #
  #   # Now check whether the data we entered is in place.
  #   user.reload
  #
  #   expect(user.phone).to eq('919876543210')
  #   expect(user.gender).to eq(User::GENDER_FEMALE)
  #   expect(user.born_on).to eq(Date.parse('1982-03-03'))
  #   expect(user.communication_address).to eq("This is\r\nwhere I live.")
  #   expect(user.district).to eq('district_name')
  #   expect(user.state).to eq('state_name')
  #   expect(user.pin).to eq('600001')
  #   expect(user.linkedin_url).to eq('https://linkedin.com/url')
  #   expect(user.twitter_url).to eq('https://twitter.com/url')
  #
  #   startup = user.startup
  #   expect(startup.product_name).to eq('Test product')
  #   expect(startup.product_description).to eq("About\nTest\nproduct")
  #   expect(startup.presentation_link).to eq('https://sv.co')
  #   expect(startup.incubation_location).to eq(Startup::INCUBATION_LOCATION_VISAKHAPATNAM)
  #   expect(startup.website).to eq('https://startupwebsite.com')
  #   expect(startup.registration_type).to eq(Startup::REGISTRATION_TYPE_PARTNERSHIP)
  #   expect(startup.startup_categories.count).to eq(3)
  #   expect(startup.startup_categories.to_a - [startup_category_1, startup_category_2, startup_category_3]).to be_empty
  #   expect(startup.team_size).to eq 1
  #   expect(startup.women_employees).to eq 0
  # end

  # context 'User has started Application' do
  #   let(:user) { create :user_with_password, confirmed_at: Time.now, phone: '9876543210' }
  #
  #   before do
  #     visit root_path
  #     click_on 'Apply for Incubation!'
  #
  #     check 'team-leader-consent'
  #     click_on 'Start incubation!'
  #   end
  #
  #   scenario 'User attempts to submit User profile without mandatory fields' do
  #     click_on 'Next Step'
  #
  #     expect(page.find('.startup_admin_gender')[:class]).to include('has-error')
  #     expect(page.find('.startup_admin_born_on')[:class]).to include('has-error')
  #   end
  #
  #   scenario 'User cancels application to SV.CO' do
  #     click_on 'Cancel Application'
  #     expect(page).to have_text('Apply for Incubation!')
  #
  #     # Now check whether data is in shape.
  #     user.reload
  #
  #     expect(user.startup).to eq(nil)
  #     expect(user.startup_admin).to be_falsey
  #     expect(user.is_founder).to be_falsey
  #   end
  #
  #   context 'User is a student' do
  #     scenario 'User picks University and supplies roll number', js: true do
  #       choose 'Female'
  #       fill_in 'Date of birth', with: '03/03/1982'
  #       expect(page).to_not have_selector('.startup_admin_roll_number')
  #       select university.name, from: 'University'
  #       expect(page).to have_selector('.startup_admin_roll_number')
  #       fill_in 'University Roll Number', with: 'R1234'
  #       attach_file 'startup_admin_attributes_college_identification', File.join(Rails.root, 'spec', 'support', 'uploads', 'users', 'college_id.jpg')
  #       click_on 'Next Step'
  #
  #       # Make sure startup profile page has loaded.
  #       expect(page).to have_text('Incubation location')
  #
  #       # Now test data.
  #       user.reload
  #
  #       expect(user.university).to eq(university)
  #       expect(user.roll_number).to eq('R1234')
  #       expect(user.college_identification).to be_present
  #     end
  #
  #     scenario 'User picks University, but does not supply roll number' do
  #       choose 'Female'
  #       fill_in 'Date of birth', with: '03/03/1982'
  #       select university.name, from: 'University'
  #       click_on 'Next Step'
  #
  #       expect(page.find('.startup_admin_roll_number')[:class]).to include('has-error')
  #     end
  #   end
  #
  #   context 'when User has submitted User profile' do
  #     before do
  #       choose 'Female'
  #       fill_in 'Date of birth', with: '03/03/1982'
  #       click_on 'Next Step'
  #     end
  #
  #     scenario 'User cancels application to SV.CO' do
  #       click_on 'Cancel Application'
  #       expect(page).to have_text('Apply for Incubation!')
  #
  #       # Now check whether data is in shape.
  #       user.reload
  #
  #       expect(user.startup).to eq(nil)
  #       expect(user.startup_admin).to be_falsey
  #       expect(user.is_founder).to be_falsey
  #     end
  #
  #     scenario 'User attempts to submit Startup profile with out-of-bound optional fields' do
  #       fill_in 'Team size', with: 0
  #       fill_in 'No. of women employees', with: -1
  #       click_on 'Submit Application'
  #
  #       expect(page.find('.startup_team_size')[:class]).to include('has-error')
  #       expect(page.find('.startup_women_employees')[:class]).to include('has-error')
  #     end
  #   end
  # end
end
