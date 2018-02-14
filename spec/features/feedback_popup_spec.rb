require 'rails_helper'

feature 'Feedback Popup' do
  include UserSpecHelper

  let(:founder) { create :founder }
  let(:startup) { create :startup }
  let!(:target_group) { create :target_group, level: startup.level, milestone: true }
  let(:faculty) { create :faculty }
  let!(:feedback) { create :startup_feedback, faculty: faculty, startup: startup }

  context 'User is not logged in' do
    scenario 'User visits the timeline page to see feedback' do
      visit product_path(startup.id, startup.slug, show_feedback: feedback.id)

      # user must be redirected to sign in page
      expect(page).to have_text('Sign in to SV.CO')

      # Log in the founder.
      sign_in_user(founder.user)

      # user must be redirected back to the startup page
      expect(page).to have_text(startup.product_name)
      expect(page).to have_text('No timeline events to show')
    end
  end

  context 'User is logged in, but not a founder of the startup' do
    scenario 'User visits timeline page and sees no feedback' do
      sign_in_user(founder.user, referer: product_path(startup.id, startup.slug, show_feedback: feedback.id))

      expect(page).to have_text(startup.product_name)

      # Feedback model should not be present.
      expect(page).not_to have_css('#improvement-modal')
      expect(page).not_to have_text("Feedback from #{faculty.name}")
    end
  end

  context 'User is a logged in founder of the startup' do
    before do
      startup.founders << founder
      startup.save!
    end

    scenario 'User is logged in as a founder of the startup', js: true do
      sign_in_user(founder.user, referer: product_path(startup.id, startup.slug, show_feedback: feedback.id))

      expect(page).to have_text(startup.product_name)

      # Feedback model should be open.
      expect(page).to have_css('.modal')

      within('div#improvement-modal') do
        expect(page).to have_text("Feedback from #{faculty.name}")
        expect(page).to have_text(feedback.feedback)
      end
    end
  end
end
