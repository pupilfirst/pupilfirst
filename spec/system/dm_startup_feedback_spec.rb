require 'rails_helper'

feature 'DM Startup Feedback', broken: true do
  include UserSpecHelper

  let!(:admin) { create :admin_user }
  let!(:startup) { create :startup }
  let!(:faculty) { create :faculty, slack_user_id: 'ABCDEFG' }
  let!(:startup_feedback) { create :startup_feedback, faculty: faculty, startup: startup }

  let!(:slack_message_for_founder_1) do
    salutation = "Hey! You have some feedback from #{startup_feedback.faculty.name} on your <#{startup_feedback.reference_url}|recent update>.\n"
    feedback_url = Rails.application.routes.url_helpers.student_url(startup_feedback.startup.founders.first.id, show_feedback: startup_feedback.id)
    coach_url = 'slack://user?team=XYZ1234&id=ABCDEFG'
    feedback_text = "<#{feedback_url}|Click here> to view the feedback.\n"
    ping_faculty = "<#{coach_url}|Discuss with Coach> about this feedback."
    { text: salutation + feedback_text + ping_faculty }.to_query
  end

  let!(:slack_message_for_founder_2) do
    salutation = "Hey! You have some feedback from #{startup_feedback.faculty.name} on your <#{startup_feedback.reference_url}|recent update>.\n"
    feedback_url = Rails.application.routes.url_helpers.student_url(startup_feedback.startup.founders.second.id, show_feedback: startup_feedback.id)
    coach_url = 'slack://user?team=XYZ1234&id=ABCDEFG'
    feedback_text = "<#{feedback_url}|Click here> to view the feedback.\n"
    ping_faculty = "<#{coach_url}|Discuss with Coach> about this feedback."
    { text: salutation + feedback_text + ping_faculty }.to_query
  end

  let!(:founder_1_request) do
    stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=UABCDEF&link_names=1'\
    "&#{slack_message_for_founder_1}&token=BOT_OAUTH_TOKEN&unfurl_links=false")
      .to_return(body: '{"ok":true}')
  end

  let!(:founder_2_request) do
    stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=U123456&link_names=1'\
    "&#{slack_message_for_founder_2}&token=BOT_OAUTH_TOKEN&unfurl_links=false")
      .to_return(body: '{"ok":true}')
  end

  before :each do
    # Create another founder in team.
    create :founder, startup: startup

    # Stub the request to intercom - we don't care about this right now.
    stub_request(:any, /api\.intercom\.io/)

    # Sign in as admin
    sign_in_user(admin.user)

    # add slack info for founders
    startup.founders.first.update!(slack_user_id: 'UABCDEF', slack_username: 'jack')
    startup.founders.second.update!(slack_user_id: 'U123456', slack_username: 'jill')
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
      click_button 'DM on Slack Now'

      expect(founder_1_request).to have_been_made.once
      expect(founder_2_request).to have_been_made.once
      expect(page).to have_text(startup_feedback.feedback)
    end

    scenario 'Admin sends DM to all founders from the show page', js: true do
      visit admin_startup_feedback_path(startup_feedback)
      expect(page).to have_text("Startup feedback ##{startup_feedback.id}")

      accept_alert do
        click_on 'Send DM to all founders.'
      end

      expect(page).to have_content("Your feedback has been sent as DM to:")
      expect(page).to have_content("jack")
      expect(page).to have_content("jill")
      expect(founder_1_request).to have_been_made.once
      expect(founder_2_request).to have_been_made.once
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
