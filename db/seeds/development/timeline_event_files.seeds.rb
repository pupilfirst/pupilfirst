require_relative 'helper'

after 'development:timeline_events' do
  puts 'Seeding timeline_event_files'

  improved_timeline_event = TimelineEvent.find_by(status: TimelineEvent::STATUS_PENDING, timeline_event_type: TimelineEventType.find_by(key: 'new_product_deck'))

  presentation_path = File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf'))

  TimelineEventFile.create!(
    timeline_event: improved_timeline_event,
    title: 'Improved presentation',
    file: File.open(presentation_path)
  )
end
