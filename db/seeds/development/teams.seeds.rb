require_relative 'helper'

after 'development:founders' do
  puts 'Seeding teams'

  Cohort.all.each do |cohort|
    next if cohort.founders.one?

    team = Team.create!(cohort: cohort, name: Faker::Company.name)
    cohort.founders.each { |founder| founder.update!(team_id: team.id) }
  end
end
