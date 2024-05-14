require "rails_helper"

feature "Students view performance report and submissions overview", js: true do
  include UserSpecHelper
  include NotificationHelper

  # The basics
  let(:course) { create :course }
  let(:cohort) { create :cohort, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:course_coach) { create :faculty, school: course.school }
  let(:team_coach) { create :faculty, school: course.school }
  let(:coach_without_access) { create :faculty, school: course.school }

  # Create a team
  let!(:team) { create :team, cohort: cohort }

  let!(:student) { create :student, team: team, cohort: cohort }
  let!(:another_student) { create :student, team: team, cohort: cohort }

  # Create few targets for the student
  let(:target_group_l1) { create :target_group, level: level_1 }
  let(:target_group_l2) { create :target_group, level: level_2 }
  let(:target_group_l3) { create :target_group, level: level_3 }

  let(:target_l1) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l1
  end
  let!(:target_with_milestone_assignment_l2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l2,
           given_milestone_number: 1
  end
  let!(:target_with_milestone_assignment_l3) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l3,
           given_milestone_number: 2
  end
  let!(:target_4) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l3
  end

  let!(:quiz_target_1) { create :target, target_group: target_group_l1 }
  let!(:assignment_quiz_target_1) do
    create :assignment, target: quiz_target_1, role: Assignment::ROLE_STUDENT
  end
  let!(:target_1_quiz) do
    create :quiz,
           :with_question_and_answers,
           assignment: assignment_quiz_target_1
  end

  let!(:quiz_target_2) { create :target, target_group: target_group_l3 }
  let!(:assignment_quiz_target_2) do
    create :assignment, target: quiz_target_2, role: Assignment::ROLE_STUDENT
  end
  let!(:target_2_quiz) do
    create :quiz,
           :with_question_and_answers,
           assignment: assignment_quiz_target_2
  end

  # Create evaluation criteria for targets
  let(:evaluation_criterion_1) { create :evaluation_criterion, course: course }
  let(:evaluation_criterion_2) { create :evaluation_criterion, course: course }

  let!(:archived_assignment) do
    create :assignment,
            :with_default_checklist,
            archived: true,
            role: Assignment::ROLE_STUDENT
  end

  # A target with an archived assignment will be marked as read
  let!(:target_with_archived_assignment) do
    create :target,
            target_group: target_group_l3,
            assignments: [archived_assignment]
  end

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
      passed_at: 3.days.ago
    )
  end
  let!(:submission_target_l1_2) do
    create(
      :timeline_event,
      students: [student],
      target: target_with_milestone_assignment_l2,
      evaluator_id: course_coach.id,
      evaluated_at: 3.days.ago,
      passed_at: nil
    )
  end
  let!(:submission_target_with_milestone_assignment_l2) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: target_with_milestone_assignment_l2,
      evaluator_id: course_coach.id,
      evaluated_at: 1.day.ago,
      passed_at: 1.day.ago
    )
  end
  let!(:submission_target_with_milestone_assignment_l3) do
    create(
      :timeline_event,
      students: [student],
      target: target_with_milestone_assignment_l3,
      evaluator_id: course_coach.id,
      evaluated_at: 1.day.ago,
      passed_at: 1.day.ago
    )
  end
  let!(:pending_submission_target_with_milestone_assignment_l3) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: target_with_milestone_assignment_l3
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

  let!(:page_read_1) do
    create :page_read, student: student, target: target_with_archived_assignment
  end

  let!(:mark_as_read_target_1) { create :target, target_group: target_group_l3 }
  let!(:mark_as_read_target_2) { create :target, target_group: target_group_l3 }

  let!(:page_read_2)  { create(:page_read, student: student, target: mark_as_read_target_1) }

  before do
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: team_coach,
           student: student

    target_l1.assignments.first.evaluation_criteria << evaluation_criterion_1
    target_with_milestone_assignment_l2.assignments.first.evaluation_criteria << [
      evaluation_criterion_1,
      evaluation_criterion_2
    ]
    target_with_milestone_assignment_l3
      .assignments
      .first
      .evaluation_criteria << evaluation_criterion_2
    target_4.assignments.first.evaluation_criteria << evaluation_criterion_2

    submission_target_l1_2.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_1,
      grade: 1
    )
    submission_target_l1_1.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_1,
      grade: 2
    )

    submission_target_with_milestone_assignment_l2.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_1,
      grade: 3
    )
    submission_target_with_milestone_assignment_l2.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_2,
      grade: 2
    )
    submission_target_with_milestone_assignment_l3.timeline_event_grades.create!(
      evaluation_criterion: evaluation_criterion_2,
      grade: 2
    )
  end

  around { |example| Time.use_zone(student.user.time_zone) { example.run } }

  scenario "student visits course report link" do
    sign_in_user student.user, referrer: report_course_path(course)

    expect(page).to have_text("Cohort")
    expect(page).to have_text(cohort.name)

    # Targets Overview
    expect(page).to have_text("Targets Overview")

    within("div[aria-label='assignments-completion-status']") do
      expect(page).to have_content("Incomplete: 1")
      expect(page).to have_content("Pending Review: 1")
      expect(page).to have_content("Completed: 4")
      expect(page).to have_content("66%")
    end

    within("div[aria-label='targets-read-status']") do
      expect(page).to have_content("Unread: 7")
      expect(page).to have_content("Read: 2")
      expect(page).to have_content("22%")
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

    # Milestone details
    expect(page).to have_text("Milestones")
    expect(page).to have_text("1 / 2")
    expect(page).to have_text("50% completed")
    # both milestones are present
    expect(page).to have_content("#{target_with_milestone_assignment_l2.title}")
    expect(page).to have_content("#{target_with_milestone_assignment_l3.title}")

    # All milestones should have the right status written next to their titles.
    within("a[href='/targets/#{target_with_milestone_assignment_l2.id}']") do
      expect(page).to have_content("Completed")
    end

    within("a[href='/targets/#{target_with_milestone_assignment_l3.id}']") do
      expect(page).to have_content("Pending")
    end

    # Coaches assigned to student
    expect(page).to have_content("Personal Coaches")
    expect(page).to have_content(team_coach.name)
    expect(page).to_not have_content(course_coach.name)

    # Checks submissions
    click_button "Submissions"

    expect(page).to have_link(target_l1.title, href: "/targets/#{target_l1.id}")
    expect(page).to_not have_content(target_4.title)

    fill_in "filter", with: "status"
    click_button "Status: Pending Review"

    expect(page).not_to have_text(target_l1.title)
    expect(page).to have_link(
      target_with_milestone_assignment_l3.title,
      href: "/targets/#{target_with_milestone_assignment_l3.id}"
    )
  end

  scenario "student loads more submissions" do
    # Create over 20 reviewed submissions
    20.times do
      submission =
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          owners: [student],
          target: target_4,
          evaluator_id: course_coach.id,
          evaluated_at: 2.days.ago,
          passed_at: 3.days.ago
        )
      submission.timeline_event_grades.create!(
        evaluation_criterion: evaluation_criterion_2,
        grade: 2
      )
    end

    sign_in_user student.user, referrer: report_course_path(course)
    expect(page).to have_text("Targets Overview")
    click_button "Submissions"
    click_button("Load More...")

    expect(page).to have_selector(
      "a[aria-label^='Student submission']",
      count: 25
    )

    # Switching tabs should preserve already loaded submissions
    click_button "Overview"
    click_button "Submissions"

    expect(page).to have_selector(
      "a[aria-label^='Student submission']",
      count: 25
    )
  end

  context "student's team members change mid-way of course" do
    let(:target_l1) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_TEAM,
             target_group: target_group_l1
    end
    let!(:submission_target_l1_1) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team.students,
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )
    end

    before do
      # Add a team member to student's team
      create :student, team: team, cohort: cohort
    end

    scenario "submissions by old team has info on effect of team change" do
      sign_in_user student.user, referrer: report_course_path(course)

      # Switch to submissions tab
      click_button "Submissions"

      # The main link should point to the "backup" submission page.
      expect(page).to have_link(
        target_l1.title,
        href: "/submissions/#{submission_target_l1_1.id}"
      )

      within(
        "div[aria-label='Team change notice for submission #{submission_target_l1_1.id}']"
      ) do
        expect(page).to have_content(
          "This submission is not counted toward the target's completion"
        )

        # There should be an additional link to the target as well.
        expect(page).to have_link(
          "View Target",
          href: "/targets/#{target_l1.id}"
        )
      end
    end
  end

  context "course has archived targets" do
    let!(:target_4) do
      create :target,
             :archived,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group_l3
    end

    let(:target_with_milestone_assignment_l3) do
      create :target,
             :archived,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group_l3
    end

    let!(:page_read_3)  { create(:page_read, student: student, target: mark_as_read_target_2) }

    scenario "checks status of total targets completed and targets read in report" do
      sign_in_user student.user, referrer: report_course_path(course)

      within("div[aria-label='assignments-completion-status']") do
        expect(page).to have_content("100%")
        expect(page).to have_content("Incomplete: 0")
        expect(page).to have_content("Pending Review: 0")
        expect(page).to have_content("Completed: 4")
      end

      within("div[aria-label='targets-read-status']") do
        expect(page).to have_content("Unread: 4")
        expect(page).to have_content("Read: 3")
        expect(page).to have_content("42%")
      end
    end
  end
end
