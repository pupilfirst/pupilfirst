require_relative "helper"

after "development:evaluation_criteria", "development:target_groups" do
  puts "Seeding targets"

  # Random targets and sessions for every level.
  TargetGroup.all.each do |target_group|
    # Create a regular submittable target.
    submittable_target =
      target_group.targets.create!(
        title: Faker::Lorem.sentence,
        visibility: "live",
        sort_index: 0
      )

    submittable_assignment =
      submittable_target.assignments.create!(
        role: Assignment.valid_roles.sample,
        discussion: true,
        checklist: [
          {
            kind: Assignment::CHECKLIST_KIND_LONG_TEXT,
            title:
              "# This is the heading for a question\n\n_And this is its body._",
            optional: false
          },
          {
            kind: Assignment::CHECKLIST_KIND_LINK,
            title: "A second question, to test multiple questions",
            optional: false
          }
        ]
      )
    submittable_assignment.assignments_evaluation_criteria.create!(
      evaluation_criterion: submittable_target.course.evaluation_criteria.sample
    )

    # Add a target that has no assignment
    target_group.targets.create!(
      title: Faker::Lorem.sentence,
      visibility: "live",
      sort_index: 1
    )

    # Add a target with a quiz - we'll create the quiz in quiz.seeds.rb.
    quiz_target =
      target_group.targets.create!(
        title: "Quiz: #{Faker::Lorem.sentence}",
        visibility: "live",
        sort_index: 2
      )

    quiz_target.assignments.create!(
      role: Assignment.valid_roles.sample,
      checklist: [],
      milestone: true,
      milestone_number:
        target_group
          .course
          .targets
          .joins(:assignments)
          .maximum("assignments.milestone_number")
          .to_i + 1
    )

    # Create two other targets in archived and draft state.
    target_group.targets.create!(
      title: Faker::Lorem.sentence,
      visibility: "archived",
      safe_to_change_visibility: true,
      sort_index: 3
    )

    target_group.targets.create!(
      title: Faker::Lorem.sentence,
      visibility: "draft",
      safe_to_change_visibility: true,
      sort_index: 4
    )

    form_submission =
      target_group.targets.create!(
        title: "Form: #{Faker::Lorem.sentence}",
        visibility: "live",
        sort_index: 5
      )
    form_submission_assignment =
      form_submission.assignments.create!(
        role: Assignment.valid_roles.sample,
        checklist: [
          {
            kind: Assignment::CHECKLIST_KIND_MULTI_CHOICE,
            title: "Do you play any sport?",
            optional: false,
            metadata: {
              choices: %w[Yes No],
              allowMultiple: false
            }
          },
          {
            kind: Assignment::CHECKLIST_KIND_LONG_TEXT,
            title: "Describe your experience playing sports",
            optional: false
          },
          {
            kind: Assignment::CHECKLIST_KIND_SHORT_TEXT,
            title: "Are you early bird or night owl?",
            optional: false,
            metadata: {
            }
          },
          {
            kind: Assignment::CHECKLIST_KIND_LINK,
            title: "Please, fill your github link",
            optional: true,
            metadata: {
            }
          }
        ]
      )
  end
end
