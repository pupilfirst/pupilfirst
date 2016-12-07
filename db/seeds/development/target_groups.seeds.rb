require_relative 'helper'

after 'development:program_weeks' do
  puts 'Seeding target groups'

  first_week = ProgramWeek.find_by(number: 1)
  first_week_group_names = ['Welcome to SV.CO!', 'Early Start to Operations', 'Program Basics', 'Get Inspired'].freeze
  second_week = ProgramWeek.find_by(number: 2)
  second_week_group_names = ['Science & Startups', 'Startup ABCs', 'Get Inspired', 'Engineering & Design ABCs'].freeze

  first_week_group_names.each_with_index do |name, index|
    TargetGroup.create!(
      name: name,
      sort_index: index + 1,
      description: Faker::Lorem.words(10).join(' '),
      program_week: first_week
    )
  end

  second_week_group_names.each_with_index do |name, index|
    TargetGroup.create!(
      name: name,
      sort_index: index + 1,
      description: Faker::Lorem.words(10).join(' '),
      program_week: second_week
    )
  end
end
