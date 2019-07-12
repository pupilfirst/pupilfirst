require_relative 'helper'

after 'development:levels' do
  puts 'Seeding target_groups'

  Level.all.each do |level|
    (1..2).each do |index|
      level.target_groups.create!(
        name: Faker::Lorem.words(2).join(' '),
        sort_index: index,
        description: Faker::Lorem.sentence,
        milestone: (milestone % 2 == 0)
      )
    end
  end
end
