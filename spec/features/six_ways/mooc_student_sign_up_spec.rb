require 'rails_helper'

feature 'MoocStudent Sign In' do
  include UserSpecHelper

  let!(:first_module) { create :course_module, :with_2_chapters, module_number: 1 }
  let!(:second_module) { create :course_module, :with_2_chapters, module_number: 2 }
  let(:college) { create :college }
  let(:mooc_student) { create :mooc_student, college: college }
  let(:first_chapter_name) { first_module.module_chapters.find_by(chapter_number: 1).name }

  before do
    create :state, name: 'Kerala'
  end

  context 'User visits the sixways start page' do
    scenario 'User signs up for MOOC', js: true do
      visit six_ways_start_path

      click_link 'Sign-up as Student'

      expect(page).to have_content('Please tell us more about yourself!')

      fill_in 'Name', with: 'John Doe'
      fill_in 'Email', with: 'johndoe@sv.co'
      fill_in 'Mobile number', with: '9876543210'
      choose 'Male'
      select "My college isn't listed", from: 'mooc_student_signup_college_id'
      fill_in 'mooc_student_signup_college_text', with: 'Doe Learning Centre'
      select 'Graduated', from: 'Semester'
      select 'Kerala', from: 'State'

      click_button 'Sign up'

      expect(page).to have_content('Sign-in link sent!')
      open_email('johndoe@sv.co')

      mooc_student = MoocStudent.last
      expect(current_email.subject).to eq("Welcome to SV.CO's SixWays MOOC")
      expect(current_email.body).to have_text("Thank you for signing up for SV.CO's SixWays MOOC.")
      expect(current_email.body).to have_text("token=#{mooc_student.user.login_token}")
      expect(current_email.body).to have_text(CGI.escape(six_ways_start_path))
    end
  end

  context 'logged in user visits sixways start page' do
    let(:user) { create :user }

    scenario 'User signs up for MOOC', js: true do
      sign_in_user(user, referer: six_ways_start_path)

      click_link 'Sign-up as Student'

      expect(page).to have_content('Please tell us more about yourself!')

      fill_in 'Name', with: 'John Doe'
      fill_in 'Mobile number', with: '9876543210'
      choose 'Male'
      select "My college isn't listed", from: 'mooc_student_signup_college_id'
      fill_in 'mooc_student_signup_college_text', with: 'Doe Learning Centre'
      select 'Graduated', from: 'Semester'
      select 'Kerala', from: 'State'

      click_button 'Sign up'

      expect(page).to have_content('You are now a registered student.')
      expect(page).to have_link('Start the Course')
    end
  end
end
