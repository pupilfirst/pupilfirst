require_relative 'helper'

after 'development:target_groups' do
  puts 'Seeding targets'

  batch = Batch.find_by(batch_number: 6)
  week_1 = batch.program_weeks.find_by(number: 1)
  week_1_group_1 = week_1.target_groups.find_by(number: 1)
  week_1_group_2 = week_1.target_groups.find_by(number: 2)
  week_1_group_3 = week_1.target_groups.find_by(number: 3)
  week_2 = batch.program_weeks.find_by(number: 2)
  week_2_group_1 = week_2.target_groups.find_by(number: 1)
  week_2_group_2 = week_2.target_groups.find_by(number: 2)

  Target.create!(
    title: 'Add Info to your Startup Profile',
    role: 'governance',
    description: Faker::Lorem.words(10).join(' '),
    target_type: Target::TYPE_TODO,
    days_to_complete: 7,
    target_group: week_1_group_1,
    batch: batch
  )

  Target.create!(
    title: 'Join Public Slack',
    role: 'governance',
    description: Faker::Lorem.words(10).join(' '),
    completion_instructions: Faker::Lorem.words(30).join(' '),
    target_type: Target::TYPE_TODO,
    days_to_complete: 7,
    target_group: week_1_group_1,
    batch: batch
  )

  Target.create!(
    title: 'Apply for a Passport',
    role: Target::ROLE_FOUNDER,
    description: Faker::Lorem.words(10).join(' '),
    completion_instructions: Faker::Lorem.words(30).join(' '),
    target_type: Target::TYPE_TODO,
    days_to_complete: 60,
    target_group: week_1_group_2,
    batch: batch
  )

  Target.create!(
    title: "Vishnu's talk: Bootcamp!",
    role: Target::ROLE_FOUNDER,
    description: Faker::Lorem.words(10).join(' '),
    completion_instructions: Faker::Lorem.words(30).join(' '),
    target_type: Target::TYPE_ATTEND,
    days_to_complete: 7,
    target_group: week_1_group_3,
    batch: batch
  )

  Target.create!(
    title: 'Execute Experiments',
    role: 'engineering',
    description: Faker::Lorem.words(10).join(' '),
    completion_instructions: Faker::Lorem.words(30).join(' '),
    target_type: Target::TYPE_TODO,
    days_to_complete: 14,
    target_group: week_2_group_1,
    batch: batch
  )

  Target.create!(
    title: 'Why Startups Fail/Succeed',
    role: Target::ROLE_FOUNDER,
    description: Faker::Lorem.words(10).join(' '),
    completion_instructions: Faker::Lorem.words(30).join(' '),
    target_type: Target::TYPE_LEARN,
    days_to_complete: 7,
    target_group: week_2_group_2,
    batch: batch
  )
end
