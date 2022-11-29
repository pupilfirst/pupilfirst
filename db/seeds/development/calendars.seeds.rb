require_relative 'helper'

after 'development:courses', 'development:cohorts' do
  puts 'Seeding calendars'

  Course.all.each do |course|
    course.calendars.create!(
      name: Faker::Lorem.name,
      description: Faker::Lorem.words(number: 3).join(' ')
    )
  end
end
