require 'rails_helper'

feature 'DM Startup Feedback' do
  let!(:admin) { create :admin_user, admin_type: 'superadmin' }
  let!(:batch) { create :batch }
  let!(:startup) { create :startup, batch: batch }
  let!(:faculty) { create :faculty }
  let!(:startup_feedback) { create :startup_feedback, faculty: faculty, startup: startup }

  before :all do
    APP_CONFIG[:slack_token] = 'xxxxxx'
  end

  after :all do
    APP_CONFIG[:slack_token] = ENV['SLACK_TOKEN']
  end

  before :each do
    # Login as admin
    visit admin_root_path
    fill_in 'admin_user_email', with: admin.email
    fill_in 'admin_user_password', with: admin.password
    click_on 'Login'

    # stub requests to slack API
    stub_request(:get, "https://slack.com/api/users.list?token=xxxxxx")
      .to_return(body: '{"ok":true,"members":[{"id":"UABCDEF","name":"founder1"},{"id":"U123456","name":"founder2"}]}')
    stub_request(:get, "https://slack.com/api/im.list?token=xxxxxx")
      .to_return(body: '{"ok":true,"ims":[{"id":"D123456","user":"U123456"},{"id":"DABCDEF","user":"UABCDEF"}]}')
    stub_request(:get, "https://slack.com/api/chat.postMessage?token=xxxxxx&channel=/.*/&text=/.*/&as_user=true")
      .to_return(body: '{"ok":true}')
  end

  context 'Admin visits startup feedback index page in AA' do
    scenario 'Admin checks for the startup feedback in the list' do
      visit admin_startup_feedback_index_path
      expect(page).to have_text('Startup Feedback')
      expect(page).to have_text(startup_feedback.feedback)
    end

    scenario 'Admin sends DM to all founders from the index page' do
      # add slack info for founders
      startup.founders.first.update!(slack_username: 'founder1')
      startup.founders.second.update!(slack_username: 'founder2')
      startup.reload
      expect(startup.founders.where.not(slack_user_id: nil).count).to eq(2)

      founder_1_request = stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=DABCDEF'\
        "&text=#{startup_feedback.as_slack_message}&token=xxxxxx")

      founder_2_request = stub_request(:get, 'https://slack.com/api/chat.postMessage?as_user=true&channel=D123456'\
        "&text=#{startup_feedback.as_slack_message}&token=xxxxxx")

      visit admin_startup_feedback_index_path
      expect(page).to have_text(startup_feedback.feedback)
      click_on 'DM on Slack Now!'

      expect(founder_1_request).to have_been_made.once
      expect(founder_2_request).to have_been_made.once
      expect(page).to have_text(startup_feedback.feedback)
    end
  end
end
