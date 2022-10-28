require_relative 'helper'

after 'development:founders' do
  puts 'Seeding teams'

  # Try to create one team in each cohort.
  Cohort.all.each do |cohort|
    next if cohort.founders.count < 4

    team = Team.create!(cohort: cohort, name: Faker::Company.name)
    cohort.founders.last(2).each { |founder| founder.update!(team_id: team.id) }
  end
end
