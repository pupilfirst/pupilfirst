require 'rails_helper'

feature 'Timeline Builder' do
  include UserSpecHelper

  let(:level) { create :level, :one }
  let(:startup) { create :startup, level: level }
  let(:founder) { startup.admin }

  let(:target_group) { create :target_group, milestone: true }
  let(:timeline_event_type) { create :timeline_event_type }

  let!(:pending_target) do
    create :target, target_group: target_group, days_to_complete: 60, timeline_event_type: timeline_event_type
  end

  let(:description) { Faker::Lorem.sentence }

  before do
    founder.update!(dashboard_toured: true)
    sign_in_user founder.user, referer: dashboard_founder_path
  end

  scenario 'Founder submits an event', js: true do
    click_button 'Add Event'
    find('.timeline-builder__textarea').set(description)

    # TODO: Enable this and the corresponding expectation below when facebook share is ready.
    # Mark to be shared on facebook
    # find('.timeline-builder__social-bar-toggle-switch-handle').click

    # Pick a cover image.
    attach_file 'Cover Image', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg')), visible: false

    # Open the link form.
    find('.timeline-builder__upload-section-tab.link-upload').click
    expect(page).to have_content('Please enter a full URL, starting with http(s).')

    fill_in 'Link Title', with: 'Link to SV.CO'
    fill_in 'URL', with: 'https://www.sv.co'
    select 'Private', from: 'Link Visibility'
    find('.timeline-builder__attachment-button').click
    expect(page).to_not have_content('Please enter a full URL, starting with http(s).') # ensure link section is closed

    find('.timeline-builder__upload-section-tab.file-upload').click
    expect(page).to have_selector('.timeline-builder__file-label')

    fill_in 'File Title', with: 'A PDF File'
    attach_file 'timeline-builder__file-input', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')), visible: false
    find('.timeline-builder__attachment-button').click
    expect(page).to_not have_selector('.timeline-builder__file-label') # ensure file section is closed

    find('.timeline-builder__upload-section-tab.date-of-event').click
    expect(page).to have_content('Date of event')

    find('.timeline-builder__attachment-button').click
    expect(page).to_not have_content('Date of event') # ensure date section is closed

    select timeline_event_type.title, from: 'Timeline Event Type'

    click_button 'Submit'

    expect(page).to have_content('Your timeline event will be reviewed soon')

    te = TimelineEvent.last

    # It should not be linked to any target.
    expect(te.target).to eq(nil)

    expect(te.description).to eq(description)
    expect(te.image).to be_present

    expect(te.links.count).to eq(1)

    link = te.links.first
    expect(link[:title]).to eq('Link to SV.CO')
    expect(link[:url]).to eq('https://www.sv.co')
    expect(link[:private]).to eq(true)

    expect(te.timeline_event_files.count).to eq(1)

    file = te.timeline_event_files.first
    expect(file.title).to eq('A PDF File')
    expect(file.file).to be_present
    expect(file.private).to eq(false)

    expect(te.event_on).to eq(Date.today)
    # expect(te.share_on_facebook).to eq(true)
  end

  scenario 'Founder encounters errors when using timeline builder', js: true do
    click_button 'Add Event'

    # File fields empty.
    find('.timeline-builder__upload-section-tab.file-upload').click
    expect(page).to have_selector('.timeline-builder__file-label')
    find('.timeline-builder__attachment-button').click

    expect(page).to have_content('Enter a valid title!')
    expect(page).to have_content('Choose a valid file!')

    find('.timeline-builder__upload-section-tab.file-upload').click
    expect(page).to_not have_selector('.timeline-builder__file-label')

    # Link fields empty.
    find('.timeline-builder__upload-section-tab.link-upload').click
    expect(page).to have_content('Please enter a full URL, starting with http(s).')
    find('.timeline-builder__attachment-button').click

    expect(page).to have_content('Enter a valid title!')
    expect(page).to have_content('Enter a valid URL!')

    find('.timeline-builder__upload-section-tab.link-upload').click
    expect(page).to_not have_content('Please enter a full URL, starting with http(s).')

    # Description just a bunch of spaces.
    find('.timeline-builder__textarea').set('   ')
    find_button('Submit').click
    expect(page).to have_content('Please add a summary describing the event.')

    find('.timeline-builder__textarea').set('description text')

    # Date missing.
    click_button 'Submit'
    expect(page).to have_content('Please select a date for the event.')

    find('.timeline-builder__upload-section-tab.date-of-event').click
    find('.timeline-builder__attachment-button').click

    # Timeline event type missing.
    find_button('Submit').click
    expect(page).to have_content('Please select an appropriate timeline event type.')

    # Facebook connect missing
    find('.timeline-builder__social-bar-toggle-switch-handle').click
    expect(page).to have_content('Facebook Connect Missing!')
  end
end
