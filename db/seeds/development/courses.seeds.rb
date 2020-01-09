after 'development:schools' do
  puts 'Seeding courses'

  school = School.first

  2.times do
    school.courses.create!(
      name: Faker::Lorem.words(2).join(' '),
      description: Faker::Lorem.paragraph,
    )
  end
end
