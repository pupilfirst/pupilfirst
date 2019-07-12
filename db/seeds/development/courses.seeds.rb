after 'development:schools' do
  puts 'Seeding courses'

  grade_labels = {
    1 => 'Not Accepted',
    2 => 'Needs Improvement',
    3 => 'Meets Expectations',
    4 => 'Exceeds Expectations'
  }

  school = School.first

  4.times do
    school.courses.create!(
      name: Faker::Lorem.words(2).join(' '),
      description: Faker::Lorem.paragraph,
      max_grade: 4, pass_grade: 2,
      grade_labels: grade_labels,
    )
  end
end
