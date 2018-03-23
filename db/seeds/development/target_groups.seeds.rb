require_relative 'helper'

after 'development:levels', 'development:tracks' do
  puts 'Seeding target_groups'

  product_track = Track.find_by!(name: 'Product')
  developer_track = Track.find_by!(name: 'Developer')

  # TODO: Improve the target group titles here when we have more info on customer-facing program.
  group_data = {
    0 => ['Welcome to SV.CO', 'Admission Process'],
    1 => ['Engineering & Design First Steps', 'Level Up'],
    2 => ['Put up a Coming Soon Page', 'Level Up'],
    3 => ['Get First Feedback', 'Level Up'],
    4 => ['Reflect on your Progress', 'Level Up'],
    5 => ['Welcome to SV.CO Developer School', 'Admission Process'],
    6 => ['Engineering & Design First Steps', 'Level Up']
  }

  Level.all.each do |level|
    group_data[level.number].each_with_index do |group_name, index|
      milestone = index == 1 # Second group from data is marked as the milestone group.

      track = if level.number == 0
        nil
      else
        milestone ? product_track : developer_track
      end

      level.target_groups.create!(
        name: group_name,
        sort_index: index + 1,
        description: Faker::Lorem.words(10).join(' '),
        milestone: milestone,
        track: track
      )
    end
  end
end
