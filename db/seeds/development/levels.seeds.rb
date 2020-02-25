require_relative 'helper'

after 'development:courses' do
  puts 'Seeding levels'

  Course.all.each do |course|
    (1..3).each do |level_number|
      Level.create!(number: level_number, name: Faker::Lorem.words(number: 3).join(' '), course: course)
    end
  end
end
