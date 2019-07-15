require_relative 'helper'

after 'development:timeline_events' do
  puts 'Seeding timeline_event_files (empty)'
end
