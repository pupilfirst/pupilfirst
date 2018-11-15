require_relative 'helper'

after 'development:timeline_events' do
  puts 'Seeding timeline_event_files'

  timeline_event = TimelineEvent.find_by(timeline_event_type: TimelineEventType.find_by(key: 'new_product_deck'))

  presentation_path = File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf'))

  TimelineEventFile.create!(
    timeline_event: timeline_event,
    title: 'Improved presentation',
    file: File.open(presentation_path)
  )
end
