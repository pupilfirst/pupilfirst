require 'helper'

after 'development:schools' do
  puts 'Seeding users'

  # Add admin user in all schools.
  School.all.each do |school|
    school.users.create!(email: 'admin@example.com', name: Faker::Lorem.name)
  end

  # Add three student users in the first school.
  school = School.first

  (1..3).each do |index|
    school.users.create!(email: "student#{index}@example.com", name: Faker::Lorem.name)
  end
end

