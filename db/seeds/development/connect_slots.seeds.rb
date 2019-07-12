require_relative 'helper'

after 'development:faculty' do
  puts 'Seeding connect_slots'

  coach_1 = Faculty.first
  coach_2 = coach_1.school.faculty.where.not(id: coach_1).first
  day = 6.days.from_now.beginning_of_day
  past_week = 6.days.ago.beginning_of_day
  past_month = 1.month.ago.beginning_of_day

  [coach_1, coach_2].each do |coach|
    coach.connect_slots.create!(slot_at: day + 8.hours)
    coach.connect_slots.create!(slot_at: day + 8.5.hours)
    coach.connect_slots.create!(slot_at: day + 16.hours)
    coach.connect_slots.create!(slot_at: day + 16.5.hours)
  end

  [coach_1, coach_2].each do |coach|
    coach.connect_slots.create!(slot_at: past_week + 8.hours)
    coach.connect_slots.create!(slot_at: past_week + 8.5.hours)
    coach.connect_slots.create!(slot_at: past_month + 12.hours)
    coach.connect_slots.create!(slot_at: past_month + 12.5.hours)
    coach.connect_slots.create!(slot_at: past_month + 16.hours)
  end
end
