require 'rails_helper'

feature 'Incubation' do
  let(:user) { create :user_with_password, confirmed_at: Time.now }

  before :all do
    APP_CONFIG[:sms_provider_url] = 'http://mobme.in'
  end

  before :each do
    # Login the user.
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Sign in'

    # Block all RestClient POST-s.
    allow(RestClient).to receive(:post)
  end

  after :all do
    APP_CONFIG[:sms_provider_url] = ENV['SMS_PROVIDER_URL']
  end

  scenario 'User applies to SV.CO' do
    visit root_path
    expect(page).to have_text('Start Application')

    click_on 'Start Application'
    expect(page).to have_text('Please supply your phone number to continue')

    fill_in 'Your phone number', with: '9876543210'
    click_on 'Proceed to phone number verification'
    expect(page).to have_text('An SMS containing a verification code has been sent to your mobile number')

    user.reload

    fill_in 'Verification code', with: user.phone_verification_code
    click_on 'Verify'
    expect(page).to have_text("Yes, I'm the Team Leader.")

    check 'team-leader-consent'
    click_on 'Start incubation!'
    expect(page).to have_text('Communication address')

    choose 'Female'
    fill_in 'Date of birth', with: '03/03/1982'
    click_on 'Next Step'
    expect(page).to have_text('Incubation location')

    fill_in 'Name', with: 'Test Startup'
    fill_in 'About', with: 'About Test Startup'
    fill_in 'Startup Deck', with: 'https://sv.co'
    select 'Visakhapatnam', from: 'Incubation location'
    click_on 'Request Invite'
    expect(page).to have_text("That's it! You're done")

    # Now check whether the data we entered is in place.
    user.reload

    expect(user.phone).to eq('919876543210')
    expect(user.gender).to eq(User::GENDER_FEMALE)
    expect(user.born_on).to eq(Date.parse('1982-03-03'))

    startup = user.startup
    expect(startup.name).to eq('Test Startup')
    expect(startup.about).to eq('About Test Startup')
    expect(startup.presentation_link).to eq('https://sv.co')
    expect(startup.incubation_location).to eq(Startup::INCUBATION_LOCATION_VISAKHAPATNAM)
  end

  context 'User has started Application' do
    let(:user) { create :user_with_password, confirmed_at: Time.now, phone: '9876543210' }

    before do
      visit root_path
      click_on 'Start Application'

      check 'team-leader-consent'
      click_on 'Start incubation!'
    end

    scenario 'User attempts to submit User profile without mandatory fields' do
      click_on 'Next Step'

      expect(page.find('.startup_admin_gender')[:class]).to include('has-error')
      expect(page.find('.startup_admin_born_on')[:class]).to include('has-error')
    end

    scenario 'User cancels application to SV.CO' do
      click_on 'Cancel Application'
      expect(page).to have_text('Start Application')

      # Now check whether data is in shape.
      user.reload

      expect(user.startup).to eq(nil)
      expect(user.startup_admin).to be_falsey
      expect(user.is_founder).to be_falsey
    end

    scenario 'User, student at a university, does not supply roll number' do

    end

    context 'when User has submitted User profile' do
      before do
        choose 'Female'
        fill_in 'Date of birth', with: '03/03/1982'
        click_on 'Next Step'
      end

      scenario 'User cancels application to SV.CO' do
        click_on 'Cancel Application'
        expect(page).to have_text('Start Application')

        # Now check whether data is in shape.
        user.reload

        expect(user.startup).to eq(nil)
        expect(user.startup_admin).to be_falsey
        expect(user.is_founder).to be_falsey
      end

      scenario 'User attempts to submit Startup profile with out-of-bound optional fields' do

      end
    end
  end
end
