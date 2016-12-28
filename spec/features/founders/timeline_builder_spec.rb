require 'rails_helper'

feature 'Timeline Builder' do
  include UserSpecHelper

  let(:startup) { create :startup }
  let(:batch) { startup.batch }
  let(:founder) { startup.admin }

  let(:program_week) { create :program_week, batch: batch, number: 1 }
  let(:target_group) { create :target_group, program_week: program_week }
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

    # Pick a cover image.
    attach_file 'Cover Image', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'users', 'college_id.jpg')), visible: false
    sleep 0.2

    # Open the link form.
    find('.timeline-builder__upload-section-tab.link-upload').click
    expect(page).to have_content('Please enter a full URL, starting with http(s).')

    fill_in 'Link Title', with: 'Link to SV.CO'
    fill_in 'URL', with: 'https://www.sv.co'
    select 'Private', from: 'Link Visibility'
    find('.timeline-builder__attachment-button').click

    # Open the file form with trigger instead of regular click to avoid animation issue.
    find('.timeline-builder__upload-section-tab.file-upload').trigger('click')
    expect(page).to have_selector('.timeline-builder__file-label')

    fill_in 'File Title', with: 'A PDF File'
    attach_file 'timeline-builder__file-input', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')), visible: false
    sleep 0.2
    find('.timeline-builder__attachment-button').click

    # Open the date form with trigger instead of regular click to avoid animation issue.
    find('.timeline-builder__upload-section-tab.date-of-event').trigger('click')
    expect(page).to have_content('Date of event')

    fill_in 'Date of Event', with: Time.zone.now.strftime('%Y-%m-%d')
    find('.timeline-builder__attachment-button').click

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
  end
end
