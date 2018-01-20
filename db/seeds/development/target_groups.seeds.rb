require_relative 'helper'

after 'development:levels' do
  puts 'Seeding target_groups'

  group_data = {
    0 => ['Admission Process', 'Welcome to SV.CO'],
    1 => ['Level Up', 'Engineering & Design First Steps'],
    2 => ['Level Up', 'Put up a Coming Soon Page'],
    3 => ['Level Up', 'Get First Feedback'],
    4 => ['Level Up', 'Reflect on your Progress']
  }

  Level.all.each do |level|
    group_data[level.number].each_with_index do |group_name, index|
      milestone = index == 0 # First group from data is marked as the milestone group.

      level.target_groups.create!(
        name: group_name,
        sort_index: index + 1,
        description: Faker::Lorem.words(10).join(' '),
        milestone: milestone
      )
    end
  end
end
