require 'rails_helper'

feature 'MoocStudent Sign In' do
  let!(:first_module) { create :course_module, :with_2_chapters, module_number: 1 }
  let!(:second_module) { create :course_module, :with_2_chapters, module_number: 2 }
  let(:mooc_student) { create :mooc_student }
  let(:first_chapter_name) { first_module.module_chapters.find_by(chapter_number: 1).name }

  context 'User visits the sixways start page' do
    before :each do
      visit six_ways_start_path
    end

    scenario 'User chooses to continue as guest' do
      click_link 'Start as Guest'

      # user must be taken to start of course
      expect(page).to have_text(first_chapter_name)

      # user must be informed he is previewing as Guest
      expect(page).to have_text('Previewing as a guest!')
    end

    scenario 'User chooses to login as Student' do
      expect(page).to_not have_link('Start the Course')

      click_link 'Sign-up as Student'
      # user must be re-directed to the sign-up form
      expect(page).to have_text('Sign up for \'#StartInCollege Six Ways\'!')

      # user should also see option to log-in instead
      expect(page).to have_text('Did this once before? Log in instead.')

      click_link 'Log in'
      # user must be re-directed to the users/sign-in page
      expect(page).to have_text('Please supply your email address.')

      # user submits email
      fill_in 'Email', with: mooc_student.email
      click_button 'Send Login Email'

      # user must be informed that login email was sent
      expect(page).to have_text('Log-in link sent!')

      # user must have received login email
      open_email(mooc_student.email)
      expect(current_email.subject).to eq('Log in to SV.CO')

      # user follows link in email and logs-in
      mooc_student.user.reload
      visit authenticate_path(token: mooc_student.user.login_token, referer: six_ways_start_path)

      # user must be logged-in and allowed to start course
      expect(page).to have_link('Start the Course')
      click_link 'Start the Course'
      expect(page).to have_text(first_chapter_name)
    end
  end
end
