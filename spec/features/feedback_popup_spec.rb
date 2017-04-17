require 'rails_helper'

feature 'Feedback Popup' do
  let(:founder) { create :founder }
  let(:startup) { create :startup }
  let!(:target_group) { create :target_group, level: startup.level, milestone: true }
  let(:faculty) { create :faculty }
  let!(:feedback) { create :startup_feedback, faculty: faculty, startup: startup }

  context 'User visits a startup page with show_feedback in url params' do
    scenario 'User is not logged in' do
      visit startup_path(startup, show_feedback: feedback.id)

      # user must be redirected to sign in page
      expect(page).to have_text('Sign in to SV.CO')

      # Log in the founder.
      visit user_token_path(token: founder.user.login_token)

      # user must be redirected back to the startup page
      expect(page).to have_text(startup.product_name)
      expect(page).to have_text('No timeline events to show')
    end

    scenario 'User is logged in but not a founder of the startup' do
      visit user_token_path(token: founder.user.login_token)

      # try to visit the startup path with show_feedback flag set
      visit startup_path(startup, show_feedback: feedback.id)

      # no feedback modal should be open
      expect(page).to have_text(startup.product_name)
      expect(page).to_not have_text("Feedback from #{faculty.name}")
    end

    scenario 'User is logged in as a founder of the startup', js: true do
      startup.founders << founder
      startup.reload

      visit user_token_path(token: founder.user.login_token)

      # try to visit the startup path with show_feedback flag set
      visit startup_path(startup, show_feedback: feedback.id)

      # no feedback modal should be open
      expect(page).to have_text(startup.product_name)
      expect(page).to have_css '.modal'

      within('div#improvement-modal') do
        expect(page).to have_text("Feedback from #{faculty.name}")
        expect(page).to have_text(feedback.feedback)
      end
    end
  end
end
