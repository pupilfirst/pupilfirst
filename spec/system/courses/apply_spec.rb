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

  context 'when public user visits the apply page' do
    scenario 'He can sign up for the course' do
      visit apply_course_path(public_course)

      expect(page).to have_content(public_course.name)
      expect(page).to have_content(public_course.description)
      fill_in 'Email', with: email
      fill_in 'Name', with: name
      click_button 'Apply'
      expect(page).to have_content("We've sent you a magic link!")
      applicant = Applicant.where(email: email).first
      expect(applicant.name).to eq(name)
      expect(applicant.email).to eq(email)
      expect(applicant.login_mail_sent_at).not_to eq(nil)

      visit enroll_applicants_path(applicant.login_token)
      expect(page).to have_content(applicant.name)
      expect(page).to have_content(public_course.name)
    end

    context 'when the applicant applied in less that two minutes ago' do
      scenario 'applicant is blocked from repeat attempts to send sign up email' do
        visit apply_course_path(public_course)

        expect(page).to have_content(public_course.name)
        fill_in 'Email', with: email_2
        fill_in 'Name', with: name_2
        click_button 'Apply'
        expect(page).to have_content("We've sent you a magic link!")

        visit apply_course_path(public_course)
        expect(page).to have_content(public_course.name)
        fill_in 'Email', with: email_2
        fill_in 'Name', with: name_2
        click_button 'Apply'
        expect(page).to have_content('An email was sent less than two minutes ago. Please wait for a few minutes before trying again')
      end
    end

    scenario "He can't see apply page for public courses in other school" do
      visit apply_course_path(public_course_in_school_2)

      expect(page).to have_text("The page you were looking for doesn't exist!")
      expect(page).not_to have_content(public_course_in_school_2.name)
    end
  end

  context 'when registered student visits a public course' do
    scenario 'He cannot apply again for the same course' do
      user = startup.founders.first.user

      visit apply_course_path(public_course)
      fill_in 'Email', with: user.email
      fill_in 'Name', with: user.name
      click_button 'Apply'
      expect(page).to have_text("Already enrolled in #{public_course.name} course")
    end
  end

  context 'when public user visits a non public course' do
    scenario 'The page should not render' do
      visit apply_course_path(private_course)

      expect(page).to have_text("The page you were looking for doesn't exist!")
      expect(page).not_to have_content(private_course.name)
    end
  end

  context 'when public user visits enroll page without a valid token' do
    scenario 'The page should redirect to signin' do
      visit enroll_applicants_path(token)

      expect(page).to have_text("Sign in")
      expect(page).to have_text('User authentication failed. The link you followed appears to be invalid.')
    end
  end
end
