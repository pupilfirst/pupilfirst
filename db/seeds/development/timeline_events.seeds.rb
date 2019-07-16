require_relative 'helper'


after 'development:founders', 'development:targets' do
  puts 'Seeding timeline_events (empty)'
end
