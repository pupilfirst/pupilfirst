require_relative "helper"

after "development:evaluation_criteria", "development:target_groups" do
  puts "Seeding targets"

  # Random targets and sessions for every level.
  TargetGroup.all.each do |target_group|
    # Create a regular submittable target.
    submittable_target =
      target_group.targets.create!(
        title: Faker::Lorem.sentence,
        role: Target.valid_roles.sample,
        resubmittable: true,
        visibility: "live",
        sort_index: 0,
        checklist: [
          {
            kind: Target::CHECKLIST_KIND_LONG_TEXT,
            title: "Write something about your submission",
            optional: false
          }
        ]
      )

    submittable_target.target_evaluation_criteria.create!(
      evaluation_criterion: submittable_target.course.evaluation_criteria.sample
    )

    # Add a target with a link to complete.
    target_group.targets.create!(
      title: Faker::Lorem.sentence,
      role: Target::ROLE_TEAM,
      link_to_complete: "https://www.example.com",
      visibility: "live",
      sort_index: 1
    )

    # Add a target that can be marked as complete.
    target_group.targets.create!(
      title: Faker::Lorem.sentence,
      role: Target::ROLE_TEAM,
      visibility: "live",
      sort_index: 2
    )

    # Add a target with a quiz - we'll create the quiz in quiz.seeds.rb.
    target_group.targets.create!(
      title: "Quiz: #{Faker::Lorem.sentence}",
      role: Target.valid_roles.sample,
      resubmittable: false,
      visibility: "live",
      sort_index: 3,
      milestone: true,
      milestone_number:
        target_group.course.targets.maximum(:milestone_number).to_i + 1
    )

    # Create two other targets in archived and draft state.
    target_group.targets.create!(
      title: Faker::Lorem.sentence,
      role: Target.valid_roles.sample,
      resubmittable: true,
      visibility: "archived",
      safe_to_change_visibility: true,
      sort_index: 4
    )

    target_group.targets.create!(
      title: Faker::Lorem.sentence,
      role: Target.valid_roles.sample,
      resubmittable: true,
      visibility: "draft",
      safe_to_change_visibility: true,
      sort_index: 5
    )

    form_submission =
      target_group.targets.create!(
        title: Faker::Lorem.sentence,
        role: Target.valid_roles.sample,
        resubmittable: true,
        visibility: "live",
        sort_index: 6,
        checklist: [
          {
            kind: Target::CHECKLIST_KIND_MULTI_CHOICE,
            title: "Do you play cricket?",
            optional: false,
            metadata: {
              choices: %w[Yes No],
              allowMultiple: false
            }
          },
          {
            kind: Target::CHECKLIST_KIND_LONG_TEXT,
            title: "Describe your cricketing experience",
            optional: false
          },
          {
            kind: Target::CHECKLIST_KIND_SHORT_TEXT,
            title: "Are you morning person or night owl?",
            optional: false,
            metadata: {
            }
          },
          {
            kind: Target::CHECKLIST_KIND_LINK,
            title: "Please, fill your portifolio link",
            optional: true,
            metadata: {
            }
          }
        ]
      )
  end
end
