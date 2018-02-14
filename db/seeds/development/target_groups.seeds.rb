require_relative 'helper'

after 'development:levels' do
  puts 'Seeding target_groups'

  group_data = {
    0 => ['Welcome to SV.CO', 'Admission Process'],
    1 => ['Engineering & Design First Steps', 'Level Up'],
    2 => ['Put up a Coming Soon Page', 'Level Up'],
    3 => ['Get First Feedback', 'Level Up'],
    4 => ['Reflect on your Progress', 'Level Up']
  }

  Level.all.each do |level|
    group_data[level.number].each_with_index do |group_name, index|
      milestone = index == 1 # Second group from data is marked as the milestone group.

      level.target_groups.create!(
        name: group_name,
        sort_index: index + 1,
        description: Faker::Lorem.words(10).join(' '),
        milestone: milestone
      )
    end
  end
end
