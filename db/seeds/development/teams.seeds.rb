require_relative 'helper'

after 'development:students' do
  puts 'Seeding teams'

  # Try to create one team in each cohort.
  Cohort.all.each do |cohort|
    next if cohort.students.count < 4

    team = Team.create!(cohort: cohort, name: Faker::Company.name)
    cohort.students.last(2).each { |student| student.update!(team_id: team.id) }
  end
end
