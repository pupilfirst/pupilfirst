require_relative 'helper'

after 'development:evaluation_criteria', 'development:target_groups' do
  puts 'Seeding targets'

  # Random targets and sessions for every level.
  TargetGroup.each do |target_group|
    # Create a regular submittable target.
    submittable_target = target_group.targets.create!(title: Faker::Lorem.sentence, role: Target.valid_roles.sample, resubmittable: true, visibility: 'live')
    submittable_target.target_evaluation_criteria.create!(evaluation_criterion: target.course.evaluation_criteria.first)

    # Add a target with a link to complete.
    target_group.targets.create!(title: Faker::Lorem.sentence, role: Target::ROLE_TEAM, link_to_complete: 'https://www.example.com', visibility: 'live')

    # Add a target that can be marked as complete.
    target_group.targets.create!(title: Faker::Lorem.sentence, role: Target::ROLE_TEAM, visibility: 'live')

    # Add a target with a quiz - we'll create the quiz in quiz.seeds.rb.
    target_group.targets.create!(title: "Quiz: #{Faker::Lorem.sentence}", role: Target.valid_roles.sample, resubmittable: true, visibility: 'live')

    # Create two other targets in archived and draft state.
    target_group.targets.create!(title: Faker::Lorem.sentence, role: Target.valid_roles.sample, resubmittable: true, visibility: 'archived', safe_to_change_visibility: true)
    target_group.targets.create!(title: Faker::Lorem.sentence, role: Target.valid_roles.sample, resubmittable: true, visibility: 'draft', safe_to_change_visibility: true)
  end
end
