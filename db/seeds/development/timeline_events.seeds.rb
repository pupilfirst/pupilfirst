after "development:students", "development:targets", "development:faculty" do
  puts "Seeding timeline events"

  school = School.find_by(name: "Test School")
  user = school.users.find_by(email: "student1@example.com")
  student = user.students.first
  course = student.course
  cohort = course.cohorts.active.first

  # Move this student to the final level of the course in an active cohort.
  final_level = course.levels.order(number: :desc).first
  student.cohort = cohort
  student.save!

  checklist = [
    {
      kind: "longText",
      title: "# This is the heading for a question\n\n_And this is its body._",
      result: "This is the answer to the question.\n\n_Also_ Markdown.",
      status: "noAnswer"
    },
    {
      kind: "link",
      title: "A second question, to test multiple questions",
      result: "https://lms.pupilfirst.org",
      status: "noAnswer"
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
          student: student
        )

        # Assign the grades for the review.
        target.evaluation_criteria.each do |criterion|
          reviewed_submission.timeline_event_grades.create!(
            evaluation_criterion_id: criterion.id,
            grade: (1..criterion.max_grade).to_a.sample
          )
        end

        # Add feedback to the graded submissions
        reviewed_submission.startup_feedback.create!(
          feedback: "Here is some feedback for the submission.",
          faculty_id: 1,
          sent_at: Time.current + Rational(500, 1000)
        )

        # Set passed_at if all grades are over the pass grade.
        if reviewed_submission
             .timeline_event_grades
             .includes(:evaluation_criterion)
             .all? { |grade|
               grade.grade >= grade.evaluation_criterion.pass_grade
             }
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
        student: student
      )

      archived =
        target.timeline_events.create!(
          checklist: checklist,
          created_at: 12.hours.ago,
          archived_at: 10.hours.ago
        )

      archived.timeline_event_owners.create!(latest: false, student: student)
    end

  form_submission_checklist = [
    {
      title:
        "Have you participated (asked or answered questions) in Pupilfirst School Discord server during WD 101 duration?",
      kind: "multiChoice",
      result: ["Yes"],
      status: "noAnswer"
    },
    {
      title:
        "If you have chosen Yes for the previous question on participation in the Discord server, type \"None\" and proceed to the next question.\n\nElse, if you have chosen No, please let us know why?",
      kind: "longText",
      result: "None",
      status: "noAnswer"
    },
    {
      title:
        "Approximately how much time did it take you to complete the WD101 course?",
      kind: "shortText",
      result: "15",
      status: "noAnswer"
    },
    {
      title: "Please, fill your github link",
      kind: "link",
      status: "noAnswer",
      result: "https://github.com"
    }
  ]

  # Add a form submission which will be auto verified
  form_submission =
    TimelineEvent.create!(
      checklist: form_submission_checklist,
      created_at: 2.hours.ago,
      target_id: 7
    )

  form_submission.timeline_event_owners.create!(latest: true, student: student)

  form_submission.update!(passed_at: 2.hours.ago)

  puts "\nStudent with submissions"
  puts "------------------------"
  puts "Email: #{user.email}"
  puts "Name: #{user.name}"
  puts "Organisation: #{user.organisation.name}"
  puts "Cohort: #{cohort.name}"
  puts "Course: #{course.name}"
  puts "------------------------"
end
