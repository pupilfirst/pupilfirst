require_relative 'helper'

after 'development:connect_slots', 'development:startups' do
  puts 'Seeding connect_requests (empty)'
end
