after 'development:founders', 'development:targets' do
  puts 'Seeding timeline events'

  school = School.find_by(name: 'Test School')
  user = school.users.find_by(email: 'student1@example.com')
  student = user.founders.first
  course = student.course
  cohort = course.cohorts.active.first

  # Move this student to the final level of the course in an active cohort.
  final_level = course.levels.order(number: :desc).first
  student.level = final_level
  student.cohort = cohort
  student.save!

  checklist = [
    {
      kind: 'longText',
      title: "# This is the heading for a question\n\n_And this is its body._",
      result: "This is the answer to the question.\n\n_Also_ Markdown.",
      status: 'noAnswer'
    },
    {
      kind: 'link',
      title: 'A second question, to test multiple questions',
      result: 'https://www.pupilfirst.com',
      status: 'noAnswer'
    }
  ]

  # Add lots of reviewed submissions.
  course
    .targets
    .joins(:target_evaluation_criteria)
    .includes(:level, :evaluation_criteria)
    .each do |target|
      # Create two such submissions per target.
      (1..2).each do |submission_number|
        # Create the submission.
        reviewed_submission =
          target.timeline_events.create!(
            evaluator: course.faculty.first,
            evaluated_at: submission_number.days.ago,
            created_at: (submission_number * 2).days.ago,
            checklist: checklist
          )

        # Assign the owner for the submission.
        reviewed_submission.timeline_event_owners.create!(
          latest: target.level.id != final_level.id && submission_number == 1,
          founder: student
        )

        # Assign the grades for the review.
        target.evaluation_criteria.each do |criterion|
          reviewed_submission.timeline_event_grades.create!(
            evaluation_criterion_id: criterion.id,
            grade: (1..criterion.max_grade).to_a.sample
          )
        end

        # Set passed_at if all grades are over the pass grade.
        if reviewed_submission
             .timeline_event_grades
             .includes(:evaluation_criterion)
             .all? do |grade|
               grade.grade >= grade.evaluation_criterion.pass_grade
             end
          reviewed_submission.update!(passed_at: submission_number.days.ago)
        end
      end
    end

  # Add a few pending review submissions and archived ones.
  course
    .targets
    .joins(:target_evaluation_criteria, :level)
    .where(levels: { id: final_level.id })
    .each do |target|
      pending_review =
        target.timeline_events.create!(
          checklist: checklist,
          created_at: 3.hours.ago
        )

      pending_review.timeline_event_owners.create!(
        latest: true,
        founder: student
      )

      archived =
        target.timeline_events.create!(
          checklist: checklist,
          created_at: 12.hours.ago,
          archived_at: 10.hours.ago
        )

      archived.timeline_event_owners.create!(latest: false, founder: student)
    end

  puts "\nStudent with submissions"
  puts '------------------------'
  puts "Email: #{user.email}"
  puts "Name: #{user.name}"
  puts "Organisation: #{user.organisation.name}"
  puts "Cohort: #{cohort.name}"
  puts "Course: #{course.name}"
  puts '------------------------'
end
