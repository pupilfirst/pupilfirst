require_relative 'helper'

after 'development:faculty' do
  puts 'Seeding connect slots'

  mickey = Faculty.find_by(email: 'mickeymouse@example.com')

  day = 6.days.from_now.beginning_of_day

  mickey.connect_slots.create!(slot_at: day + 8.hours)
  mickey.connect_slots.create!(slot_at: day + 8.5.hours)
  mickey.connect_slots.create!(slot_at: day + 16.hours)
  mickey.connect_slots.create!(slot_at: day + 16.5.hours)
end
