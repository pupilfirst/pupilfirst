require_relative 'helper'

after 'development:faculty' do
  puts 'Seeding connect_slots'

  mickey = Faculty.find_by(email: 'mickeymouse@example.com')
  minnie = Faculty.find_by(email: 'minniemouse@example.com')
  day = 6.days.from_now.beginning_of_day
  past_week = 6.days.ago.beginning_of_day
  past_month = 1.month.ago.beginning_of_day

  [mickey, minnie].each do |faculty|
    faculty.connect_slots.create!(slot_at: day + 8.hours)
    faculty.connect_slots.create!(slot_at: day + 8.5.hours)
    faculty.connect_slots.create!(slot_at: day + 16.hours)
    faculty.connect_slots.create!(slot_at: day + 16.5.hours)
  end

  [mickey, minnie].each do |faculty|
    faculty.connect_slots.create!(slot_at: past_week + 8.hours)
    faculty.connect_slots.create!(slot_at: past_week + 8.5.hours)
    faculty.connect_slots.create!(slot_at: past_month + 12.hours)
    faculty.connect_slots.create!(slot_at: past_month + 12.5.hours)
    faculty.connect_slots.create!(slot_at: past_month + 16.hours)
  end
end
