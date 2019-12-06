require 'rails_helper'

feature "Apply for public courses", js: true do
  include UserSpecHelper

  # The basics.
  let(:school) { create :school, :current }
  let(:school_2) { create :school }
  let(:public_course) { create :course, school: school, public_signup: true }
  let!(:level_one) { create :level, course: public_course }
  let(:private_course) { create :course, school: school }
  let(:public_course_in_school_2) { create :course, school: school_2, public_signup: true }
  let(:name) { Faker::Name.name }
  let(:email) { Faker::Internet.email(name) }
  let(:name_2) { Faker::Name.name }
  let(:email_2) { Faker::Internet.email(name_2) }
  let(:old_applicant) { create :applicant, course: course }
  let(:startup) { create :startup, level: level_one }
  let(:token) { Faker::Crypto.md5 }

  scenario 'public sign up for a public course' do
    visit apply_course_path(public_course)

    expect(page).to have_content(public_course.name)
    fill_in 'Email', with: email
    fill_in 'Name', with: name
    click_button 'Apply'

    expect(page).to have_content("We've sent you a verification mail")

    applicant = Applicant.where(email: email).first

    expect(applicant.name).to eq(name)
    expect(applicant.email).to eq(email)
    expect(applicant.login_mail_sent_at).not_to eq(nil)

    open_email(email)
    expect(current_email.body).to include(public_course.name)
    expect(current_email.body).to include(applicant.login_token)

    visit enroll_applicants_path(applicant.login_token)

    expect(page).to have_content("Welcome to #{school.name}!")
    expect(page).to have_content(applicant.name)
    expect(page).to have_content(public_course.name)
  end

  scenario 'applicant tries to sign up multiple times in quick succession' do
    visit apply_course_path(public_course)

    expect(page).to have_content(public_course.name)

    fill_in 'Email', with: email_2
    fill_in 'Name', with: name_2
    click_button 'Apply'

    expect(page).to have_content("We've sent you a verification mail")

    visit apply_course_path(public_course)

    expect(page).to have_content(public_course.name)

    fill_in 'Email', with: email_2
    fill_in 'Name', with: name_2
    click_button 'Apply'

    expect(page).to have_content('An email was sent less than two minutes ago. Please wait for a few minutes before trying again')
  end

  scenario "user visits a public course in other school" do
    visit apply_course_path(public_course_in_school_2)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(public_course_in_school_2.name)
  end

  scenario 'a student in the course tries public enrollment' do
    user = startup.founders.first.user

    visit apply_course_path(public_course)
    fill_in 'Email', with: user.email
    fill_in 'Name', with: user.name
    click_button 'Apply'

    expect(page).to have_text("Already enrolled in #{public_course.name} course")
  end

  scenario 'user tries to access a private course page' do
    visit apply_course_path(private_course)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(private_course.name)
  end

  scenario 'user tries to access enrollment page without a valid token' do
    visit enroll_applicants_path(token)

    expect(page).to have_text("Sign in")
    expect(page).to have_text('User authentication failed. The link you followed appears to be invalid.')
  end

  scenario 'user visits apply URL with email and name as query parameters' do
    name = Faker::Name.name
    email = Faker::Internet.email(name)
    visit apply_course_path(public_course, name: name, email: email)

    expect(page).to have_selector("input[value='#{name}']")
    expect(page).to have_selector("input[value='#{email}']")
  end

  context 'when school has privacy policy' do
    before do
      create :school_string, :privacy_policy, school: school
      create :school_string, :terms_of_use, school: school_2
    end

    scenario 'applicant can only see link to the privacy policy' do
      visit apply_course_path(public_course)

      expect(page).to have_link('Privacy Policy', href: '/agreements/privacy-policy')
      expect(page).not_to have_link('Terms of Use', href: '/agreements/terms-of-use')
    end
  end

  context 'when school has terms of use' do
    before do
      create :school_string, :privacy_policy, school: school_2
      create :school_string, :terms_of_use, school: school
    end

    scenario 'applicant can only see link to the terms of use' do
      visit apply_course_path(public_course)

      expect(page).not_to have_link('Privacy Policy', href: '/agreements/privacy-policy')
      expect(page).to have_link('Terms of Use', href: '/agreements/terms-of-use')
    end
  end

  context 'when school has both agreements' do
    before do
      create :school_string, :privacy_policy, school: school
      create :school_string, :terms_of_use, school: school
    end

    scenario 'applicant can see links to both agreements' do
      visit apply_course_path(public_course)

      expect(page).to have_link('Privacy Policy', href: '/agreements/privacy-policy')
      expect(page).to have_link('Terms of Use', href: '/agreements/terms-of-use')
    end
  end
end
