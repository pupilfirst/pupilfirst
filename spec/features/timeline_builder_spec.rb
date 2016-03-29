require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Timeline Builder' do
  let(:founder) { create :founder_with_password, confirmed_at: Time.now, timeline_toured: true }
  let!(:tet_team_formed) { create :tet_team_formed }
  let(:startup) { create :startup }

  let(:event_description) { Faker::Lorem.words(10).join ' ' }

  before :all do
    WebMock.allow_net_connect!
  end

  after :all do
    WebMock.disable_net_connect!
  end

  before :each do
    # Add founder as founder of startup.
    startup.founders << founder

    # Log in the founder.
    visit new_founder_session_path
    fill_in 'founder_email', with: founder.email
    fill_in 'founder_password', with: 'password'
    click_on 'Sign in'

    # founder should now be on the startup timeline page.
  end

  context 'Founder visits Timeline page of verified startup' do
    scenario 'Founder submits new timeline event', js: true do
      # Type in description.
      fill_in 'timeline_event_description', with: event_description

      # Choose type of event.
      click_on 'Type of Event'
      page.find('.select2-result-label', text: 'Team Formed').click

      # Pick date. There's a gotcha with QT4 here, it doesn't reliably pick today's date, unlike QT5.
      page.find('#timeline_event_event_on').click
      page.find('.dtpicker-buttonSet').click

      # Can't figure out how to attach files to hidden file fields.
      # page.attach_file('timeline_event_image', File.join(Rails.root, '/app/assets/images/favicon.png'), visible: false)

      # Add one Link.
      page.find('a', text: 'Add Links and Files').click
      click_on 'Add a link'
      fill_in 'Title', with: 'SV.CO'
      fill_in 'URL', with: 'https://sv.co'
      page.find('#link_private').click
      click_on 'Save Link'

      # And a file.
      click_on 'Attach a file'
      fill_in 'timeline-event-file-title', with: 'Sample PDF'
      attach_file 'timeline-event-file-input', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf'))
      click_on 'Save File'

      click_on 'Close'

      # HACK: Our slow CI servers often fail to click submit since the modal is still disappearing.
      sleep(0.5)

      click_on 'Submit for Review'

      # Wait for AJAX request to finish.
      expect(page).to have_text('All done!')

      # Get the timeline entry for last created event.
      last_timeline_event = TimelineEvent.order('id DESC').first

      # Sleep for 2s, since that's the delay to page refresh.
      sleep 2

      # Then wait for page to load.
      new_event_selector = "#event-#{last_timeline_event.id}"
      latest_timeline_event_entry = page.find(new_event_selector, match: :first)

      expect(latest_timeline_event_entry).to have_text('Pending verification')
      expect(latest_timeline_event_entry).to have_text('Team Formed')
      expect(latest_timeline_event_entry).to have_text(event_description)
      expect(latest_timeline_event_entry).to have_link('SV.CO')
      expect(latest_timeline_event_entry).to have_link('Sample PDF')
      expect(latest_timeline_event_entry).to have_selector('i.fa.fa-user-secret')
    end

    scenario 'Founder attempts to add link without supplying title or URL', js: true do
      page.find('a', text: 'Add Links and Files').click
      click_on 'Add a link'
      click_on 'Save Link'

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

        # Turbolinks is in effect, so wait for event to load.
        expect(page).to have_selector('textarea', text: unverified_timeline_event.description)

        fill_in 'timeline_event_description', with: new_description
        click_on 'Submit for Review'

        # Wait for AJAX request to finish.
        expect(page).to have_text('All done!')

        # Sleep for 2s, since that's the delay to page refresh.
        sleep 2

        # Then wait for page to load.
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

        # Turbolinks is in effect, so wait for event to load.
        expect(page).to have_selector('textarea', text: verified_timeline_event.description)

        fill_in 'timeline_event_description', with: new_description

        page.accept_confirm do
          click_on 'Submit for Review'
        end

        # Wait for AJAX request to finish.
        expect(page).to have_text('All done!')

        # Sleep for 2s, since that's the delay to page refresh.
        sleep 2

        # Then wait for page to load.
        new_timeline_event_panel = page.find("#event-#{verified_timeline_event.id}")
        expect(new_timeline_event_panel).to have_text(new_description)
        expect(new_timeline_event_panel).to have_text('Pending verification')

        verified_timeline_event.reload

        expect(verified_timeline_event.verified_at).to be_nil
      end

      scenario 'Founder adds multiple links', js: true do
        visit startup_path(startup)
        page.find("#event-#{verified_timeline_event.id} .edit-link").click

        # Wait for page to load.
        expect(page).to have_selector('textarea', text: verified_timeline_event.description)
        # Add two links, one private and one public.
        page.find('a', text: 'Add Links and Files').click
        click_on 'Add a link'
        fill_in 'Title', with: 'SV.CO'
        fill_in 'URL', with: 'https://sv.co'
        page.find('#link_private').click
        click_on 'Save Link'
        click_on 'Add a link'
        fill_in 'Title', with: 'Google'
        fill_in 'URL', with: 'https://www.google.com'
        click_on 'Save Link'
        click_on 'Close'

        # Test if link tab's title reflects links added
        expect(page.find('#add-link')).to have_text('SV.CO (+1)')

        # HACK: Our slow CI servers often fail to click submit since the modal is still disappearing.
        sleep(0.5)

        click_on 'Submit for Review'

        # Wait for AJAX request to finish.
        expect(page).to have_text('All done!')

        # Sleep for 2s, since that's the delay to page refresh.
        sleep 2

        # Then wait for page to load.
        # Get the timeline entry for last created event.
        last_timeline_event = TimelineEvent.order('id DESC').first
        latest_timeline_event_entry = page.find("#event-#{last_timeline_event.id}", match: :first)

        expect(latest_timeline_event_entry).to have_link('SV.CO')
        expect(latest_timeline_event_entry).to have_link('Google')
        expect(latest_timeline_event_entry.find('.tl-link-button', match: :first)).to have_selector('i.fa.fa-user-secret')
        expect(latest_timeline_event_entry.find('.tl-link-button', text: 'Google')).to_not have_selector('i.fa.fa-user-secret')
      end

      context 'Founder has a existing timeline event with one link and one file' do
        let(:timeline_event_file) { create :timeline_event_file }

        let!(:timeline_event) do
          timeline_event = create :timeline_event, startup: startup, links: [{ title: 'Google', url: 'https://google.com', private: true }]
          timeline_event.timeline_event_files << timeline_event_file
          timeline_event
        end

        scenario 'Founder deletes link', js: true do
          visit startup_path(startup)
          page.find("#event-#{timeline_event.id} .edit-link").click
          expect(page.find('#add-link')).to have_text("#{timeline_event_file.title} (+1)")
          page.find('#add-link').click
          expect(page).to have_text('Links and Files')
          attachment = page.find('.list-group-item', match: :first)
          expect(attachment).to have_text('Google')
          attachment.find('a', text: 'Delete').click

          # Test if attachments list was updated
          expect(page).to have_selector('.list-group-item', count: 1)
          remaining_attachment = page.find('.list-group-item', match: :first)
          expect(remaining_attachment).to have_text(timeline_event_file.title)

          click_on 'Close'
          expect(page.find('#add-link')).to have_text(timeline_event_file.title)

          # HACK: Our slow CI servers often fail to click submit since the modal is still disappearing.
          sleep(0.5)

          click_on 'Submit for Review'

          # Wait for AJAX request to finish.
          expect(page).to have_text('All done!')

          # Sleep for 2s, since that's the delay to page refresh.
          sleep 2

          # Then wait for page to load.
          expect(page.find("#event-#{timeline_event.id} .tl-footer")).to_not have_text('Google')
          timeline_event.reload
          expect(timeline_event.links.length).to eq(0)
        end

        scenario 'Founder deletes file', js: true do
          visit startup_path(startup)
          page.find("#event-#{timeline_event.id} .edit-link").click
          expect(page.find('#add-link')).to have_text("#{timeline_event_file.title} (+1)")
          page.find('#add-link').click

          expect(page).to have_text('Links and Files')

          file = page.all('.list-group-item').last

          page.accept_confirm do
            file.find('a', text: 'Delete').click
          end

          expect(file).to have_text 'Marked for Deletion'

          click_on 'Close'
          expect(page.find('#add-link')).to have_text('Google')

          # HACK: Our slow CI servers often fail to click submit since the modal is still disappearing.
          sleep(0.5)

          click_on 'Submit for Review'

          # Wait for AJAX request to finish.
          expect(page).to have_text('All done!')

          # Sleep for 2s, since that's the delay to page refresh.
          sleep 2

          # Then wait for page to load.
          expect(page.find("#event-#{timeline_event.id} .tl-footer")).to_not have_text(timeline_event_file.title)
          timeline_event.reload
          expect(timeline_event.timeline_event_files.count).to eq(0)
        end

        scenario 'Founder edits one of the links', js: true do
          visit startup_path(startup)
          page.find("#event-#{timeline_event.id} .edit-link").click
          expect(page.find('#add-link')).to have_text("#{timeline_event_file.title} (+1)")
          page.find('#add-link').click
          first_link = page.find('.list-group-item', match: :first)
          expect(first_link).to have_text('Google')
          first_link.find('a', text: 'Edit').click

          # Test if form was pre-populated with existing details
          expect(page).to have_selector('#link_title')
          expect(page.find('#link_title').value).to eq(timeline_event.links.first[:title])
          expect(page).to have_selector('#link_url')
          expect(page.find('#link_url').value).to eq(timeline_event.links.first[:url])
          expect(page).to have_selector('#link_private')
          expect(page.find('#link_private')).to be_checked

          # update all three fields
          new_title = 'Facebook'
          new_url = 'https://www.facebook.com'
          fill_in 'Title', with: new_title
          fill_in 'URL', with: new_url
          page.find('#link_private').set(false)
          click_on 'Save Link'

          # Test if link list was updated
          expect(page).to have_selector('.list-group-item', count: 2)
          expect(page.find('.list-group-item', match: :first)).to have_text('Facebook')
          click_on 'Close'

          # HACK: Our slow CI servers often fail to click submit since the modal is still disappearing.
          sleep(0.5)

          click_on 'Submit for Review'

          # Wait for AJAX request to finish.
          expect(page).to have_text('All done!')

          # Sleep for 2s, since that's the delay to page refresh.
          sleep 2

          # Then wait for page to load.
          expect(page.find("#event-#{timeline_event.id} .tl-footer")).to_not have_text('Google')
          expect(page.find("#event-#{timeline_event.id} .tl-footer")).to have_text('Facebook')
          timeline_event.reload
          expect(timeline_event.links.length).to eq(1)
          expect(timeline_event.links.first[:title]).to eq('Facebook')
        end

        scenario 'Founder adds a third and final link', js: true do
          visit startup_path(startup)
          page.find("#event-#{timeline_event.id} .edit-link").click
          expect(page.find('#add-link')).to have_text("#{timeline_event_file.title} (+1)")
          page.find('#add-link').click
          click_on 'Add a link'
          fill_in 'Title', with: 'SV.CO'
          fill_in 'URL', with: 'https://sv.co'
          page.find('#link_private').click
          click_on 'Save Link'

          # Test if link list was updated
          expect(page).to have_selector('.list-group-item', count: 3)
          # Ensure 'Add a link' button is not shown
          expect(page).to_not have_selector('button', text: 'Add a link')
          click_on 'Close'
          expect(page.find('#add-link')).to have_text("#{timeline_event_file.title} (+2)")

          # HACK: Our slow CI servers often fail to click submit since the modal is still disappearing.
          sleep(0.5)

          click_on 'Submit for Review'

          # Wait for AJAX request to finish.
          expect(page).to have_text('All done!')

          # Sleep for 2s, since that's the delay to page refresh.
          sleep 2

          # Then wait for page to load.
          expect(page.find("#event-#{timeline_event.id} .tl-footer")).to have_text('SV.CO')
          timeline_event.reload
          expect(timeline_event.links.length).to eq(2)
          expect(timeline_event.links.last[:title]).to eq('SV.CO')
        end
      end
    end
  end
end
