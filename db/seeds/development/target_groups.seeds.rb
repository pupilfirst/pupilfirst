require_relative 'helper'

after 'development:program_weeks' do
  puts 'Seeding target groups'

  # create six groups per week
  group_names_by_week = [
    ['Welcome to SV.CO!', 'Early Start to Operations', 'Program Basics', 'Get Inspired', 'Your Idea Shortlist', 'Engineering & Design First Steps'].freeze,
    ['Science & Startups', 'Startup ABCs', 'Get Inspired', 'Engineering & Design ABCs', 'Your Idea', 'Personal ABCs'].freeze,
    ['Your Startup Detailed', 'Engineering & Design Trial Run', 'Get Inspired', 'Startup at the Launchpad', 'Early Pitch Deck', 'Startup Success'].freeze,
    ['Initial Product Workflow', 'Get Inspired', 'Engineering Workflow', 'Put up a Coming Soon Page', 'Prepare for Design Sprint', 'Startup Success'].freeze
  ]

  group_names_by_week.each_with_index do |group_names, week_index|
    program_week = ProgramWeek.find_by(number: week_index + 1)
    group_names.each_with_index do |name, index|
      TargetGroup.create!(
        name: name,
        sort_index: index + 1,
        description: Faker::Lorem.words(10).join(' '),
        program_week: program_week
      )
    end
  end
end
