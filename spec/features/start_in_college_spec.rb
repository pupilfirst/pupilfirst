require 'rails_helper'

feature 'Signing up for the StartinCollege course' do
  context 'when no login_token is present in the cookies' do
    scenario 'user visits the course start page' do
      visit start_in_college_start_path

      # must have redirected to the login page
      expect(page).to have_text('Please supply your basic details')

      fill_in 'user_email', with: 'someone@example.com'
      click_on 'Register / Login'

      # login email should be send and user notified
      expect(ActionMailer::Base.deliveries.last).to have_text('Please click here to login to your SV.CO account!')
      expect(page).to have_text('Please visit your inbox to continue')
    end
  end

  # context 'when a valid login_token is present in the cookies' do
  #   let!(:user) { create :user }
  #
  #   scenario 'user visits the course start page' do
  #     cookies.permanent.signed[:login_token] = { value: user.login_token, domain: :all }
  #     visit start_in_college_start_path
  #
  #     # must have reached the coruse start page
  #     # TODO: change text when page content is finalized
  #     expect(page).to have_text('This is the start page of the course')
  #   end
  # end
end
