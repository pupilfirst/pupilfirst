require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Timeline Builder' do
  let(:user) { create :user_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }

  let(:event_description) { Faker::Lorem.words(10).join ' ' }

  before :all do
    WebMock.allow_net_connect!

    [
      ['team_formed','Governance','Team Formed','We are a bunch of [Technology/Music/...] enthusiasts from [College/City] and we are excited to start! Our team has Name (Role), Name 2 (Role 2), ...','Not Needed',nil,'team_formation'],
      ['new_product_deck','Product','New Product Deck','We just updated our Product Deck, do take a look!','Link to new deck','moved_to_idea_discovery','idea'],
      ['one_liner','Governance','Set New One-Liner','We have set a new one-line mission for our product! We want to [organize the worlds information/...]. We think this mission is great because [...].','Not Needed','moved_to_idea_discovery,moved_to_customer_validation','mission']
    ].each do |event_type|
      TimelineEventType.create!(
        key: event_type[0],
        role: event_type[1],
        title: event_type[2],
        sample_text: event_type[3],
        proof_required: event_type[4],
        suggested_stage: event_type[5],
        badge: File.open(File.join(Rails.root, '/app/assets/images/seeds/timeline_event_types/default.png')),
      )
    end
  end

  before :each do
    # Add user as founder of startup.
    startup.founders << user

    # Log in the user.
    visit new_user_session_path
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_on 'Sign in'

    # User should now be on the startup timeline page.
  end

  context 'Founder visits Timeline page of verified startup' do
    scenario 'Founder submits new timeline event', js: true, focus: true do
      # Type in description.
      fill_in 'timeline_event_description', with: event_description

      # Choose type of event.
      click_on 'Type of Event'
      page.find('.select2-result-label', text: 'Team Formed').click

      # Pick date.
      page.find('#timeline_event_event_on').click
      page.find('.dtpicker-buttonSet').click

      # TODO: File attachment doesn't seem to work. Might be because of https://github.com/ariya/phantomjs/issues/12506
      page.attach_file('timeline_event_image', File.join(Rails.root, '/app/assets/images/favicon.png'), visible: false)

      # Add Link.
      page.find('a', text: 'Add a Link').click
      fill_in 'Title', with: 'SV.CO'
      fill_in 'URL', with: 'https://sv.co'
      click_on 'Add'

      click_on 'Submit for Review'

      latest_timeline_event_panel = page.first('.timeline-panel')

      expect(latest_timeline_event_panel).to have_text('Pending verification')
      expect(latest_timeline_event_panel).to have_text('Team Formed')
      expect(latest_timeline_event_panel).to have_text(event_description)
      expect(latest_timeline_event_panel).to have_link('SV.CO', href: 'https://sv.co')
    end
  end

  # TODO: Test limiting of description.

  after :all do
    WebMock.disable_net_connect!
  end
end
