require 'rails_helper'

feature 'DM Startup Feedback' do
  include UserSpecHelper

  let!(:admin) { create :admin_user, admin_type: 'superadmin' }
  let!(:startup) { create :startup }
  let!(:faculty) { create :faculty, slack_user_id: 'ABCDEFG' }
  let!(:startup_feedback) { create :startup_feedback, faculty: faculty, startup: startup }

  let!(:slack_message) do
    salutation = "Hey! You have some feedback from #{startup_feedback.faculty.name} on your <#{startup_feedback.reference_url}|recent update>.\n"
    feedback_url = Rails.application.routes.url_helpers.timeline_url(startup_feedback.startup.id, startup_feedback.startup.slug, show_feedback: startup_feedback.id)
    faculty_url = 'slack://user?team=XYZ1234&id=ABCDEFG'
    feedback_text = "<#{feedback_url}|Click here> to view the feedback.\n"
    ping_faculty = "<#{faculty_url}|Discuss with Faculty> about this feedback."
    { text: salutation + feedback_text + ping_faculty }.to_query
  end

  let!(:founder_1_request) do
    stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=UABCDEF&link_names=1'\
    "&#{slack_message}&token=BOT_OAUTH_TOKEN&unfurl_links=false")
      .to_return(body: '{"ok":true}')
  end

  let!(:founder_2_request) do
    stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=U123456&link_names=1'\
    "&#{slack_message}&token=BOT_OAUTH_TOKEN&unfurl_links=false")
      .to_return(body: '{"ok":true}')
  end

  before :each do
    # Sign in as admin
    sign_in_user(admin.user)

    # add slack info for founders
    startup.founders.first.update!(slack_user_id: 'UABCDEF')
    startup.founders.second.update!(slack_user_id: 'U123456')
    startup.reload
  end

  context 'Admin visits startup feedback index page in AA' do
    scenario 'Admin checks for the startup feedback in the list' do
      visit admin_startup_feedback_index_path
      expect(page).to have_text('Startup Feedback')
      expect(page).to have_text(startup_feedback.feedback)
    end

    scenario 'Admin sends DM to all founders from the index page' do
      visit admin_startup_feedback_index_path
      expect(page).to have_text(startup_feedback.feedback)
      click_on 'DM on Slack Now'

      expect(founder_1_request).to have_been_made.once
      expect(founder_2_request).to have_been_made.once
      expect(page).to have_text(startup_feedback.feedback)
    end

    scenario 'Admin sends DM to all founders from the show page' do
      visit admin_startup_feedback_path(startup_feedback)
      expect(page).to have_text("Startup feedback ##{startup_feedback.id}")
      click_on 'Send DM to all founders.'

      expect(founder_1_request).to have_been_made.once
      expect(founder_2_request).to have_been_made.once
      expect(page).to have_text("Startup feedback ##{startup_feedback.id}")
    end

    scenario 'Admin sends DM to a selected founder from the show page' do
      visit admin_startup_feedback_path(startup_feedback)
      expect(page).to have_text("Startup feedback ##{startup_feedback.id}")
      click_on 'Send DM'

      expect(founder_1_request).to have_been_made.once
      expect(founder_2_request).not_to have_been_made
      expect(page).to have_text("Startup feedback ##{startup_feedback.id}")
    end
  end
end
