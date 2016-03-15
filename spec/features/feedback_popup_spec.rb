require 'rails_helper'

feature 'Feedback Popup' do
  let(:founder) { create :founder_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup }
  let(:faculty) { create :faculty }
  let!(:feedback) { create :startup_feedback, faculty: faculty, startup: startup }

  before :all do
    WebMock.allow_net_connect!
  end

  after :all do
    WebMock.disable_net_connect!
  end

  context 'User visits a startup page with show_feedback in url params' do
    scenario 'User is not logged in' do
      visit startup_path(startup, show_feedback: feedback.id)

      # user must be redirected to login page
      expect(page).to have_text('Login with your SV.CO ID')

      fill_in 'founder_email', with: founder.email
      fill_in 'founder_password', with: 'password'
      click_on 'Sign in'

      # user must be redirected back to the startup page
      expect(page).to have_text(startup.product_name)
      expect(page).to have_text('No timeline events to show')
    end

    scenario 'User is logged in but not a founder of the startup' do
      visit new_founder_session_path
      fill_in 'founder_email', with: founder.email
      fill_in 'founder_password', with: 'password'
      click_on 'Sign in'

      # try to visit the startup path with show_feedback flag set
      visit startup_path(startup, show_feedback: feedback.id)

      # no feedback modal should be open
      expect(page).to have_text(startup.product_name)
      expect(page).to_not have_text("Feedback from #{faculty.name}")
    end

    scenario 'User is logged in as a founder of the startup', js: true do
      startup.founders << founder
      startup.reload
      visit new_founder_session_path
      fill_in 'founder_email', with: founder.email
      fill_in 'founder_password', with: 'password'
      click_on 'Sign in'

      # try to visit the startup path with show_feedback flag set
      visit startup_path(startup, show_feedback: feedback.id)

      # no feedback modal should be open
      expect(page).to have_text(startup.product_name)
      expect(page).to have_css ".modal"
      within('div#improvement-modal') do
        expect(page).to have_text("Feedback from #{faculty.name}")
        expect(page).to have_text(feedback.feedback)
      end
    end
  end
end
