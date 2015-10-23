require 'rails_helper'

feature 'About / Contact Spec' do
  let(:user) { create :user_with_password, confirmed_at: Time.now, phone: '9876543210' }
  let(:startup) { create :startup }

  before :all do
    Recaptcha.configure do |config|
      config.public_key  = '6Lc6BAAAAAAAAChqRbQZcn_yyyyyyyyyyyyyyyyy'
      config.private_key = '6Lc6BAAAAAAAAKN3DRm6VA_xxxxxxxxxxxxxxxxx'
    end
  end

  context 'Founder is logged in' do
    before :each do
      # Add user as founder of startup.
      startup.founders << user

      # Log in the user.
      visit new_user_session_path
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'password'
      click_on 'Sign in'
    end

    scenario 'Founder of startup visits contact page' do
      visit about_contact_path

      expect(page).to have_selector("input[value='#{user.fullname}']")
      expect(page).to have_selector("input[value='#{user.email}']")
      expect(page).to have_selector("input[value='#{user.startup.display_name}']")
    end
  end

  scenario 'User attempts to submit contact form without required fields' do
    visit about_contact_path

    click_on 'Submit'

    expect(page).to have_selector('.form-group.has-error', count: 3)
  end

  scenario 'User submits contact form' do
    visit about_contact_path

    name = Faker::Name.name
    email = Faker::Internet.email(name)
    mobile = (9_000_000_000 + rand(999_999_999)).to_s
    company = Faker::Company.name
    query = Faker::Lorem.words(50).join ' '

    fill_in 'Your name', with: name
    fill_in 'Email address', with: email
    fill_in 'Mobile phone number', with: mobile
    fill_in 'Company you represent', with: company
    fill_in 'Query', with: query

    click_on 'Submit'

    # Wait for page to load.
    expect(page).to have_text('Contact')

    open_email('help@sv.co')

    expect(current_email.subject).to include('Media Relations Query')
    expect(current_email.body).to include(name)
    expect(current_email.body).to include(email)
    expect(current_email.body).to include(mobile)
    expect(current_email.body).to include(company)
    expect(current_email.body).to include(query)
  end
end
