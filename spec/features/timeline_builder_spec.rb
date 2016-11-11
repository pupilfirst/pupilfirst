require 'rails_helper'

# WARNING: The following tests run with Webmock disabled - i.e., URL calls are let through. Make sure you mock possible
# requests unless you want to let them through. This is required for JS tests to work.
feature 'Timeline Builder' do
  let(:founder) { create :founder, confirmed_at: Time.now, timeline_toured: true }
  let!(:tet_team_formed) { create :tet_team_formed }
  let(:startup) { create :startup }

  let(:event_description) { Faker::Lorem.words(10).join ' ' }

  before :each do
    # Add founder as founder of startup.
    startup.founders << founder

    # Log in the founder.
    visit user_token_path(token: founder.user.login_token)

    # Founder should now be on the startup timeline page (no referer needed).
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
      click_button 'Add a link'
      fill_in 'Title', with: 'SV.CO'
      fill_in 'URL', with: 'https://sv.co'
      page.find('#link_private').click
      click_button 'Save Link'

      # And a file.
      click_button 'Attach a file'
      fill_in 'timeline-event-file-title', with: 'Sample PDF'
      attach_file 'timeline-event-file-input', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf'))
      click_on 'Save File'
      click_on 'Close'
      click_on 'Submit for Review'

      # Wait for AJAX request to finish.
      expect(page).to have_text('All done!')

      # Get the timeline entry for last created event.
      last_timeline_event = TimelineEvent.order('id DESC').first

      # Then wait for page to load with a waiting selector.
      new_event_selector = "#event-#{last_timeline_event.id}"
      expect(page).to have_selector(new_event_selector, text: /pending verification/i)

      latest_timeline_event_entry = page.find(new_event_selector, match: :first)
      expect(latest_timeline_event_entry).to have_text('Team Formed')
      expect(latest_timeline_event_entry).to have_text(event_description)
      expect(latest_timeline_event_entry).to have_link('SV.CO')
      expect(latest_timeline_event_entry).to have_link('Sample PDF')
      expect(latest_timeline_event_entry).to have_selector('i.fa.fa-user-secret')
    end

    scenario 'Founder attempts to add link without supplying title or URL', js: true do
      page.find('a', text: 'Add Links and Files').click
      click_button 'Add a link'
      click_button 'Save Link'

      expect(page).to have_selector('#link-title-group.has-error')
      expect(page).to have_selector('#link-url-group.has-error')
    end

    scenario 'Founder attempts to submit builder without essential fields', js: true do
      click_on 'Submit for Review'

      expect(page).to have_selector('textarea.description.has-error')
      expect(page).to have_selector('#timeline_event_event_on.has-error')
      expect(page).to have_selector('.select2-container.has-error')
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
        expect(page).to have_selector('form.edit_timeline_event')

        expect(page).to have_selector('textarea', text: unverified_timeline_event.description)

        fill_in 'timeline_event_description', with: new_description
        click_on 'Submit for Review'

        # Wait for AJAX request to finish.
        expect(page).to have_text('All done!')

        # Ensure the description updates.
        event_selector = "#event-#{unverified_timeline_event.id}"
        expect(page).to have_selector(event_selector, text: 'Pending verification')
        expect(page).to have_selector(event_selector, text: new_description)
      end

      scenario 'Founder adds multiple links', js: true do
        visit startup_path(startup)
        page.find("#event-#{unverified_timeline_event.id} .edit-link").click

        # Wait for page to load.
        expect(page).to have_selector('form.edit_timeline_event')

        expect(page).to have_selector('textarea', text: unverified_timeline_event.description)
        # Add two links, one private and one public.
        page.find('a', text: 'Add Links and Files').click

        within '#add-link-modal' do
          click_button 'Add a link'
          fill_in 'Title', with: 'SV.CO'
          fill_in 'URL', with: 'https://sv.co'
          check 'link_private'
          click_button 'Save Link'
          click_button 'Add a link'

          fill_in 'Title', with: 'Google'
          fill_in 'URL', with: 'https://www.google.com'
          click_button 'Save Link'
          click_button 'Close'
        end

        # Test if link tab's title reflects links added
        expect(page.find('#add-link')).to have_text('SV.CO (+1)')

        click_on 'Submit for Review'

        # Wait for AJAX request to finish.
        expect(page).to have_text('All done!')

        # There should be a secret link on the page.
        last_timeline_event = TimelineEvent.order('id DESC').first
        timeline_event_selector = "#event-#{last_timeline_event.id}"
        expect(page).to have_selector(timeline_event_selector + ' .tl-link-button i.fa.fa-user-secret')
        expect(page.find(timeline_event_selector + ' .tl-link-button', text: 'SV.CO')).to have_selector('i.fa.fa-user-secret')
        expect(page.find(timeline_event_selector + ' .tl-link-button', text: 'Google')).to_not have_selector('i.fa.fa-user-secret')
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

          # Wait for Tubrolinks load.
          expect(page).to have_selector('form.edit_timeline_event')
          expect(page.find('#add-link')).to have_text("#{timeline_event_file.title} (+1)")
          page.find('#add-link').click

          within '#add-link-modal' do
            expect(page).to have_selector('.list-group-item', text: 'Google')

            within('.list-group-item', text: 'Google') do
              click_button 'Delete'
            end

            # Test if attachments list was updated
            expect(page).to have_selector('.list-group-item', count: 1)
            expect(page).to have_selector('.list-group-item', text: timeline_event_file.title)

            click_on 'Close'
          end

          expect(page).to have_selector('#add-link', text: timeline_event_file.title)

          click_on 'Submit for Review'

          # Wait for AJAX request to finish.
          expect(page).to have_text('All done!')

          timeline_event.reload
          expect(timeline_event.links.length).to eq(0)

          # The link should then disappear on reload.
          expect(page).to_not have_selector("#event-#{timeline_event.id} .tl-footer", text: 'Google')
        end

        scenario 'Founder deletes file', js: true do
          visit startup_path(startup)
          page.find("#event-#{timeline_event.id} .edit-link").click

          # Wait for page to load.
          expect(page).to have_selector('form.edit_timeline_event')

          expect(page.find('#add-link')).to have_text("#{timeline_event_file.title} (+1)")
          page.find('#add-link').click

          within '#add-link-modal' do
            expect(page).to have_text('Links and Files')

            within('.list-group-item', text: timeline_event_file.title) do
              page.accept_confirm do
                click_button 'Delete'
              end
            end

            expect(page).to have_selector('.list-group-item', text: 'Marked for Deletion')

            click_button 'Close'
          end

          expect(page).to have_selector('#add-link', text: 'Google')

          click_on 'Submit for Review'

          # Wait for AJAX request to finish.
          expect(page).to have_text('All done!')

          timeline_event.reload
          expect(timeline_event.timeline_event_files.count).to eq(0)

          # The file should then disappear on reload.
          expect(page).to_not have_selector("#event-#{timeline_event.id} .tl-footer", text: timeline_event_file.title)
        end

        scenario 'Founder edits one of the links', js: true do
          visit startup_path(startup)
          page.find("#event-#{timeline_event.id} .edit-link").click

          # Wait for page to load.
          expect(page).to have_selector('form.edit_timeline_event')

          expect(page.find('#add-link')).to have_text("#{timeline_event_file.title} (+1)")
          page.find('#add-link').click

          within('.list-group-item', text: 'Google') do
            click_button 'Edit'
          end

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
          click_button 'Save Link'

          # Test if link list was updated
          expect(page).to have_selector('.list-group-item', count: 2)
          expect(page.find('.list-group-item', match: :first)).to have_text('Facebook')
          click_on 'Close'

          click_on 'Submit for Review'

          # Wait for AJAX request to finish.
          expect(page).to have_text('All done!')

          timeline_event.reload
          expect(timeline_event.links.length).to eq(1)
          expect(timeline_event.links.first[:title]).to eq('Facebook')

          # Then ensure that the view updates.
          expect(page).to_not have_selector("#event-#{timeline_event.id} .tl-footer", text: 'Google')
          expect(page).to have_selector("#event-#{timeline_event.id} .tl-footer", text: 'Facebook')
        end

        scenario 'Founder adds a third and final link', js: true do
          visit startup_path(startup)
          page.find("#event-#{timeline_event.id} .edit-link").click

          # Wait for page to load.
          expect(page).to have_selector('#add-link', text: "#{timeline_event_file.title} (+1)")
          page.find('#add-link').click
          click_button 'Add a link'
          fill_in 'Title', with: 'SV.CO'
          fill_in 'URL', with: 'https://sv.co'
          page.find('#link_private').click
          click_button 'Save Link'

          # Test if link list was updated
          expect(page).to have_selector('.list-group-item', count: 3)

          # Ensure 'Add a link' button is not shown
          expect(page).to_not have_selector('button', text: 'Add a link')
          click_on 'Close'

          expect(page).to have_selector('#add-link', text: "#{timeline_event_file.title} (+2)")

          click_on 'Submit for Review'

          # Wait for AJAX request to finish.
          expect(page).to have_text('All done!')

          timeline_event.reload
          expect(timeline_event.links.length).to eq(2)
          expect(timeline_event.links.last[:title]).to eq('SV.CO')

          # Then ensure final link is visible
          expect(page).to have_selector("#event-#{timeline_event.id} .tl-footer", text: 'SV.CO')
        end
      end
    end

    context 'Founder has a existing rejected timeline event' do
      let!(:rejected_timeline_event) { create :timeline_event, startup: startup, verified_status: TimelineEvent::VERIFIED_STATUS_NOT_ACCEPTED }
      let(:new_description) { Faker::Lorem.words(10).join ' ' }

      scenario 'Founder edits rejected event', js: true do
        visit startup_path(startup)

        expect(page).to have_selector("#event-#{rejected_timeline_event.id}", text: 'Not Accepted')

        page.find("#event-#{rejected_timeline_event.id} .edit-link").click

        expect(page).to have_selector('textarea', text: rejected_timeline_event.description)

        fill_in 'timeline_event_description', with: new_description
        click_on 'Submit for Review'

        expect(page).to have_text('All done!')

        # Ensure view updates.
        timeline_event_selector = "#event-#{rejected_timeline_event.id}"
        expect(page).to have_selector(timeline_event_selector, text: 'Pending verification')
        expect(page).to have_selector(timeline_event_selector, text: new_description)
      end
    end

    context 'Founder has a existing verified timeline event' do
      let!(:verified_timeline_event) do
        create :timeline_event, startup: startup, verified_status: TimelineEvent::VERIFIED_STATUS_VERIFIED, verified_at: Time.now
      end

      scenario 'Founder attempts to edit verified event' do
        visit startup_path(startup)

        # edit and delete buttons should be disabled
        expect(page).to have_selector("#event-#{verified_timeline_event.id} .edit-link.disabled")
        expect(page).to have_selector("#event-#{verified_timeline_event.id} .delete-link.disabled")
      end
    end

    context 'Founder has a existing needs_improvement timeline event' do
      let!(:needs_improvement_timeline_event) do
        create :timeline_event, startup: startup, verified_status: TimelineEvent::VERIFIED_STATUS_NEEDS_IMPROVEMENT, verified_at: Time.now
      end

      scenario 'Founder attempts to edit needs_improvement event' do
        visit startup_path(startup)

        # edit and delete buttons should be disabled
        expect(page).to have_selector("#event-#{needs_improvement_timeline_event.id} .edit-link.disabled")
        expect(page).to have_selector("#event-#{needs_improvement_timeline_event.id} .delete-link.disabled")
      end
    end
  end
end
