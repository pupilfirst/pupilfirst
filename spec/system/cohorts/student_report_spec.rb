require "rails_helper"

feature "Course students report", js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper

  # The basics
  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let!(:cohort) { create :cohort, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:course_coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }
  let(:coach_without_access) { create :faculty, school: school }
  let(:school_admin) { create :school_admin }
  let!(:standing) { create :standing, default: true }

  # Create a team
  let!(:team) { create :team, cohort: cohort }

  let!(:student) { create :student, cohort: cohort, team: team }

  let!(:another_student) { create :student, cohort: cohort, team: team }

  # Create few targets for the student
  let(:target_group_l1) { create :target_group, level: level_1 }

  let(:target_group_l2) { create :target_group, level: level_2 }

  let(:target_group_l3) { create :target_group, level: level_3 }

  let(:target_l1) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l1,
           given_milestone_number: 1
  end

  let(:target_l2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l2,
           given_milestone_number: 2
  end

  let(:target_l3_1) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l3
  end

  let!(:target_l3_2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l3
  end

  # Create an assignment that is archived
  let!(:archived_assignment) do
    create :assignment,
            :with_default_checklist,
            archived: true,
            role: Assignment::ROLE_STUDENT
  end

  # Link archived_assignment to target
  let!(:target_with_archived_assignment) do
    create :target,
            target_group: target_group_l3,
            assignments: [archived_assignment]
  end

  # Let's add page_read for target_with_archived_assignment
  let!(:page_read_1) do
    create :page_read, student: student, target: target_with_archived_assignment
  end

  let!(:mark_as_read_target) { create :target, target_group: target_group_l3 }
  let!(:page_read_2)  { create(:page_read, student: student, target: mark_as_read_target) }

  let(:quiz_target_1) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l1
  end

  let(:quiz_target_2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l3
  end

  # Create evaluation criteria for targets
  let(:evaluation_criterion_1) { create :evaluation_criterion, course: course }
  let(:evaluation_criterion_2) { create :evaluation_criterion, course: course }

  # Create submissions for relevant targets
  let!(:submission_target_l1_1) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: target_l1,
      evaluator_id: course_coach.id,
      evaluated_at: 2.days.ago,
      passed_at: nil
    )
  end

  let!(:submission_target_l1_2) do
    create(
      :timeline_event,
      students: [student],
      target: target_l1,
      evaluator_id: course_coach.id,
      evaluated_at: 3.days.ago,
      passed_at: 3.days.ago
    )
  end

  let!(:submission_target_l2) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: target_l2,
      evaluator_id: course_coach.id,
      evaluated_at: 1.day.ago,
      passed_at: 1.day.ago
    )
  end

  let!(:submission_target_l3_1) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: target_l3_1,
      evaluator_id: course_coach.id,
      evaluated_at: 1.day.ago,
      passed_at: 1.day.ago
    )
  end

  let!(:submission_quiz_target_1) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: quiz_target_1,
      passed_at: 1.day.ago,
      quiz_score: "1/3"
    )
  end

  let!(:submission_quiz_target_2) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: quiz_target_2,
      passed_at: 1.day.ago,
      quiz_score: "3/5"
    )
  end

  # Lets add submission for archived assignment
  let!(:submission_target_with_archived_assignment) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: target_with_archived_assignment,
      passed_at: 1.day.ago
    )
  end

  let!(:coach_note_1) do
    create :coach_note, author: course_coach.user, student: student
  end

  let!(:coach_note_2) do
    create :coach_note, author: team_coach.user, student: student
  end

  before do
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: team_coach,
           student: student

    target_l1.assignments.first.evaluation_criteria << evaluation_criterion_1

    target_l2.assignments.first.evaluation_criteria << [
      evaluation_criterion_1,
      evaluation_criterion_2
    ]

    target_l3_1.assignments.first.evaluation_criteria << evaluation_criterion_2
    target_l3_2.assignments.first.evaluation_criteria << evaluation_criterion_2

    submission_target_l1_2.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_1,
      grade: 1
    )

    submission_target_l1_1.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_1,
      grade: 3
    )

    submission_target_l2.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_1,
      grade: 2
    )

    submission_target_l2.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_2,
      grade: 2
    )

    submission_target_l3_1.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_2,
      grade: 2
    )

    school.update!(configuration: { enable_standing: true })
  end

  around do |example|
    Time.use_zone(course_coach.user.time_zone) { example.run }
  end

  scenario "coach opens the student report and checks performance" do
    sign_in_user course_coach.user, referrer: cohorts_course_path(course)

    click_link cohort.name

    click_link "Students", href: students_cohort_path(cohort)

    expect(page).to have_text(student.name)

    click_link student.name

    expect(page).to have_text("Cohort")
    expect(page).to have_text(cohort.name)

    expect(page).to have_text("Standing")
    expect(page).to have_text(standing.name)

    school.update!(configuration: { enable_standing: false })

    visit current_path

    expect(page).not_to have_text("Standing")
    expect(page).not_to have_text(standing.name)

    # Only milestones should be shown for completion status
    expect(page).to have_text(target_l1.title)
    expect(page).to have_text(target_l2.title)
    expect(page).not_to have_text(target_l3_1.title)

    # Check target completion status
    within("div[data-milestone-id='#{target_l1.id}']") do
      expect(page).to have_selector(".text-orange-700")
    end

    within("div[data-milestone-id='#{target_l2.id}']") do
      expect(page).to have_selector(".text-green-600")
    end

    # Targets Overview
    expect(page).to have_text("Targets Overview")

    within("div[aria-label='assignments-completion-status']") do
      expect(page).to have_content("Total Assignments Completed")
      expect(page).to have_content("66%")
      expect(page).to have_content("4/6 Assignments")
    end

    within("div[aria-label='targets-read-status']") do
      expect(page).to have_content("Total Targets Read")
      expect(page).to have_content("25%")
      expect(page).to have_content("2/8 Targets")
    end

    within("div[aria-label='quiz-performance-chart']") do
      expect(page).to have_content("Average Quiz Score")
      expect(page).to have_content("46%")
      expect(page).to have_content("2 Quizzes Attempted")
    end

    # Average Grades
    expect(page).to have_text("Average Grades")

    within(
      "div[aria-label='average-grade-for-criterion-#{evaluation_criterion_1.id}']"
    ) do
      expect(page).to have_content(evaluation_criterion_1.name)
      expect(page).to have_content("2.5/3")
    end

    within(
      "div[aria-label='average-grade-for-criterion-#{evaluation_criterion_2.id}']"
    ) do
      expect(page).to have_content(evaluation_criterion_2.name)
      expect(page).to have_content("2/3")
    end

    # Check submissions of student
    find("li", text: "Submissions").click

    expect(page).to have_content(target_l1.title)
    expect(page).to_not have_content(target_l3_2.title)

    within(
      "div[aria-label='student-submission-card-#{submission_target_l1_1.id}']"
    ) { expect(page).to have_content("Rejected") }

    within(
      "div[aria-label='student-submission-card-#{submission_target_l1_2.id}']"
    ) { expect(page).to have_content("Completed") }

    within("div[aria-label='student-submissions']") do
      expect(page).to have_link(
        href: "/submissions/#{submission_target_l1_1.id}/review"
      )
      expect(page).to have_link(
        href: "/submissions/#{submission_target_l3_1.id}/review"
      )
    end
  end

  scenario "coach loads more submissions" do
    # Create over 20 reviewed submissions
    20.times do
      submission =
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          owners: [student],
          target: target_l3_2,
          evaluator_id: course_coach.id,
          evaluated_at: 2.days.ago,
          passed_at: 3.days.ago
        )
      submission.timeline_event_grades.create!(
        evaluation_criterion: evaluation_criterion_2,
        grade: 2
      )
    end

    sign_in_user course_coach.user, referrer: student_report_path(student)
    expect(page).to have_text(student.name)
    find("li", text: "Submissions").click
    expect(page).to have_button("Load More...")
    click_button("Load More...")

    within("div[aria-label='student-submissions']") do
      expect(page).to have_selector(
        "a",
        count: student.timeline_events.evaluated_by_faculty.count
      )
    end

    # Switching tabs should preserve already loaded submissions
    find("li", text: "Notes").click
    find("li", text: "Submissions").click

    within("div[aria-label='student-submissions']") do
      expect(page).to have_selector(
        "a",
        count: student.timeline_events.evaluated_by_faculty.count
      )
    end
  end

  scenario "team coach accesses student report" do
    sign_in_user team_coach.user, referrer: student_report_path(student)

    # Check a student parameter
    within("div[aria-label='assignments-completion-status']") do
      expect(page).to have_content("Total Assignments Completed")
      expect(page).to have_content("66%")
      expect(page).to have_content("4/6 Assignments")
    end

    within("div[aria-label='targets-read-status']") do
      expect(page).to have_content("Total Targets Read")
      expect(page).to have_content("25%")
      expect(page).to have_content("2/8 Targets")
    end

    # Check submissions
    find("li", text: "Submissions").click
    expect(page).to have_content(target_l1.title)
    expect(page).to_not have_content(target_l3_2.title)

    within(
      "div[aria-label='student-submission-card-#{submission_target_l1_1.id}']"
    ) { expect(page).to have_content("Rejected") }

    within(
      "div[aria-label='student-submission-card-#{submission_target_l1_2.id}']"
    ) { expect(page).to have_content("Completed") }

    # Check notes
    find("li", text: "Notes").click
    expect(page).to have_text(coach_note_1.note)
    expect(page).to have_text(coach_note_2.note)

    accept_confirm do
      within("div[aria-label='Note #{coach_note_2.id}']") do
        find("button[title='Delete note #{coach_note_2.id}']").click
      end
    end
    dismiss_notification
    expect(page).to_not have_text(coach_note_2.note)
    expect(coach_note_2.reload.archived_at).to_not eq(nil)

    within("div[aria-label='Note #{coach_note_1.id}']") do
      expect(page).not_to have_selector(".fa-trash-alt")
    end
  end

  scenario "coach adds few notes for a student" do
    sign_in_user course_coach.user, referrer: student_report_path(student)

    find("li", text: "Notes").click
    note_1 = Faker::Markdown.sandwich(sentences: 2)
    note_2 = Faker::Markdown.sandwich(sentences: 2)
    add_markdown(note_1)
    click_button("Save Note")
    dismiss_notification
    expect(page).to have_text(course_coach.name)
    expect(page).to have_text(course_coach.title)
    expect(CoachNote.where(student: student).last.note).to eq(note_1)

    add_markdown(note_2)
    click_button("Save Note")
    dismiss_notification
    expect(page).to have_text(course_coach.name, count: 3)
    expect(page).to have_text(course_coach.title, count: 3)
    expect(page).to have_text(Time.zone.today.strftime("%B %-d"), count: 4)
    expect(CoachNote.where(student: student).last.note).to eq(note_2)
  end

  context "when a coach sees existing notes on the report page" do
    scenario "coach can archive her own notes" do
      sign_in_user team_coach.user, referrer: student_report_path(student)

      expect(page).to have_text(coach_note_1.note)
      expect(page).to have_text(coach_note_2.note)

      accept_confirm do
        within("div[aria-label='Note #{coach_note_2.id}']") do
          find("button[title='Delete note #{coach_note_2.id}']").click
        end
      end

      dismiss_notification
      expect(page).to_not have_text(coach_note_2.note)
      expect(coach_note_2.reload.archived_at).to_not eq(nil)
    end

    scenario "coach cannot archive others' notes" do
      sign_in_user team_coach.user, referrer: student_report_path(student)

      within("div[aria-label='Note #{coach_note_1.id}']") do
        expect(page).not_to have_selector(".fa-trash-alt")
      end
    end

    scenario "coach is indicated if there are no notes" do
      another_student = team.students.last
      sign_in_user team_coach.user,
                   referrer: student_report_path(another_student)
      expect(page).to have_text("No notes here!")
    end
  end

  scenario "unauthorized coach attempts to access student report" do
    sign_in_user coach_without_access.user,
                 referrer: student_report_path(student)
    expect(page).to have_content("The page you were looking for doesn't exist")
  end

  context "when there are more than one team coaches" do
    let(:team_coach_2) { create :faculty, school: school }

    before do
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: team_coach_2,
             student: student
    end

    scenario "coach checks list of directly assigned team coaches" do
      sign_in_user course_coach.user, referrer: student_report_path(student)

      expect(page).to have_text(team_coach.name)
      expect(page).to have_text(team_coach_2.name)
    end
  end

  scenario "coach can navigate to other team members in the team" do
    sign_in_user course_coach.user, referrer: student_report_path(student)

    team
      .students
      .where.not(id: student)
      .each do |teammate|
        expect(page).to have_link(
          teammate.name,
          href: "/students/#{teammate.id}/report"
        )
      end
  end

  scenario "coach is shown a warning about a student being dropped out" do
    time = 1.day.ago
    student.update!(dropped_out_at: time)

    sign_in_user course_coach.user, referrer: student_report_path(student)

    expect(page).to have_text(
      "This student dropped out of the course on #{time.strftime("%b %-d, %Y")}."
    )
  end

  scenario "coach is shown a warning about a student's access to a course having ended" do
    time = 1.day.ago
    cohort.update!(ends_at: time)
    sign_in_user course_coach.user, referrer: student_report_path(student)

    expect(page).to have_text(
      "This student's access to the course ended on #{time.strftime("%b %-d, %Y")}."
    )
  end

  context "when user is a school admin" do
    let!(:school_2) { create :school }
    let!(:course_2) { create :course, school: school_2 }
    let!(:cohort_2) { create :cohort, course: course_2 }
    let!(:user_2) { create :user, school: school_2 }
    let!(:school_2_student) { create :student, user: user_2, cohort: cohort_2 }

    scenario "can access a student report" do
      sign_in_user school_admin.user, referrer: student_report_path(student)
      expect(page).to have_text(student.name)

      expect(page).not_to have_text("Add a New Note")
      expect(page).not_to have_button("Save Note")

      # Can access student submissions tab
      find("li", text: "Submissions").click

      expect(page).to have_content(target_l1.title)
    end

    scenario "admin cannot access the report of a student belonging to another school" do
      sign_in_user school_admin.user,
                   referrer: student_report_path(school_2_student)

      expect(page).to have_content(
        "The page you were looking for doesn't exist"
      )
    end
  end

  context "when the user is a student" do
    let(:student_2) { create :student }

    scenario "student cannot access another student's report" do
      sign_in_user student.user, referrer: student_report_path(student_2)
      expect(page).to have_content(
        "The page you were looking for doesn't exist"
      )
    end

    scenario "student cannot access their own report" do
      sign_in_user student.user, referrer: student_report_path(student)

      expect(page).to have_content(
        "The page you were looking for doesn't exist"
      )
    end
  end
end
