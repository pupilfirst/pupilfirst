require 'rails_helper'

feature 'DM Startup Feedback' do
  let!(:admin) { create :admin_user, admin_type: 'superadmin' }
  let!(:batch) { create :batch }
  let!(:startup) { create :startup, batch: batch }
  let!(:faculty) { create :faculty }
  let!(:startup_feedback) { create :startup_feedback, faculty: faculty, startup: startup }

  let!(:founder_1_request) do
    stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=DABCDEF'\
    "&text=#{startup_feedback.as_slack_message}&token=xxxxxx&unfurl_links=false")
      .to_return(body: '{"ok":true}')
  end
  let!(:founder_2_request) do
    stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=D123456'\
    "&text=#{startup_feedback.as_slack_message}&token=xxxxxx&unfurl_links=false")
      .to_return(body: '{"ok":true}')
  end

  before :all do
    APP_CONFIG[:slack_token] = 'xxxxxx'
  end

  after :all do
    APP_CONFIG[:slack_token] = ENV['SLACK_TOKEN']
  end

  before :each do
    # Sign in as admin
    visit admin_root_path
    fill_in 'admin_user_email', with: admin.email
    fill_in 'admin_user_password', with: admin.password
    click_on 'Login'

    # stub requests to slack API
    stub_request(:get, "https://slack.com/api/users.list?token=xxxxxx")
      .to_return(body: '{"ok":true,"members":[{"id":"UABCDEF","name":"founder1"},{"id":"U123456","name":"founder2"}]}')
    stub_request(:get, "https://slack.com/api/im.open?token=xxxxxx&user=UABCDEF")
      .to_return(body: '{"ok":true,"channel":{"id":"DABCDEF"}}')
    stub_request(:get, "https://slack.com/api/im.open?token=xxxxxx&user=U123456")
      .to_return(body: '{"ok":true,"channel":{"id":"D123456"}}')

    # add slack info for founders
    startup.founders.first.update!(slack_username: 'founder1')
    startup.founders.second.update!(slack_username: 'founder2')
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
      click_on 'DM on Slack Now!'

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
