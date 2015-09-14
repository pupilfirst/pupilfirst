require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Timeline Builder' do
  let(:user) { create :user_with_password, confirmed_at: Time.now }
  let(:startup) { create :startup, approval_status: Startup::APPROVAL_STATUS_APPROVED }
  let!(:tet_one_liner) { create :tet_one_liner }
  let!(:tet_new_product_deck) { create :tet_new_product_deck }
  let!(:tet_team_formed) { create :tet_team_formed }

  let(:event_description) { Faker::Lorem.words(10).join ' ' }

  before :all do
    WebMock.allow_net_connect!
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
    scenario 'Founder submits new timeline event', js: true do
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

    scenario 'Founder attempts to add link without supplying title or URL', js: true do
      page.find('a', text: 'Add a Link').click
      click_on 'Add'

      expect(page.find('#link-title-group')[:class]).to include('has-error')
      expect(page.find('#link-url-group')[:class]).to include('has-error')
    end

    scenario 'Founder attempts to submit builder without essential fields', js: true do
      click_on 'Submit for Review'

      expect(page.find('textarea.description')[:class]).to include('has-error')
      expect(page.find('#timeline_event_event_on')[:class]).to include('has-error')
      expect(page.find('.select2-container')[:class]).to include('has-error')
    end

    scenario "Founder attempts to enter description larger than #{TimelineEvent::MAX_DESCRIPTION_CHARACTERS} characters", js: true do
      fill_in 'timeline_event_description', with: Faker::Lorem.words(TimelineEvent::MAX_DESCRIPTION_CHARACTERS / 2).join(' ')

      expect(page.find('textarea.description').value.length).to eq(TimelineEvent::MAX_DESCRIPTION_CHARACTERS)
    end

    context 'Founder has a existing unverified timeline event' do
      let!(:unverified_timeline_event) { create :timeline_event, startup: startup }
      let(:new_description) { Faker::Lorem.words(10).join ' ' }

      scenario 'Founder edits existing event', js: true do
        visit startup_path(startup)

        page.find("#event-#{unverified_timeline_event.id} .edit-link").click
        fill_in 'timeline_event_description', with: new_description
        click_on 'Submit for Review'

        new_timeline_event_panel = page.find("#event-#{unverified_timeline_event.id}")
        expect(new_timeline_event_panel).to have_text(new_description)
      end
    end

    context 'Founder has a existing verified timeline event' do
      let!(:verified_timeline_event) { create :timeline_event, startup: startup, verified_at: Time.now }
      let(:new_description) { Faker::Lorem.words(10).join ' ' }

      scenario 'Founder edits existing event', js: true do
        visit startup_path(startup)

        page.find("#event-#{verified_timeline_event.id} .edit-link").click
        fill_in 'timeline_event_description', with: new_description

        # TODO: Can't test confirmation dialogues with Poltergeist, for the moment. https://github.com/teampoltergeist/poltergeist/pull/516
        # page.accept_confirm do
        #   click_on 'Submit for Review'
        # end

        click_on 'Submit for Review'

        new_timeline_event_panel = page.find("#event-#{verified_timeline_event.id}")
        expect(new_timeline_event_panel).to have_text(new_description)

        verified_timeline_event.reload

        expect(verified_timeline_event.verified_at).to be_nil
      end
    end
  end

  after :all do
    WebMock.disable_net_connect!
  end
end
