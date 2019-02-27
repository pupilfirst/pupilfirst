require_relative 'helper'

after 'development:timeline_events' do
  puts 'Seeding timeline_event_files'

  startup = Startup.find_by(name: 'iOS Startup')
  timeline_event = TimelineEvent.joins(:founders).where(founders: { id: startup.founders.pluck(:id) }).last
  presentation_path = File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf'))

  tef = TimelineEventFile.new(
    timeline_event: timeline_event,
    title: 'Improved presentation',
    private: false
  )

  tef.file.attach(io: File.open(presentation_path), filename: 'pdf-sample.pdf')
  tef.save!
end
