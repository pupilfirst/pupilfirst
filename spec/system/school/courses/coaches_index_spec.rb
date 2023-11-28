require "rails_helper"

feature "Course Coaches Index", js: true do
  include UserSpecHelper
  include SubmissionsHelper

  # Setup a course with a single student target, ...
  let!(:school) { create :school, :current }
  let!(:school_2) { create :school }
  let!(:course_1) { create :course, school: school }
  let!(:cohort_1) { create :cohort, course: course_1 }
  let!(:course_2) { create :course, school: school }
  let!(:cohort_2) { create :cohort, course: course_2 }

  let!(:coach_1) { create :faculty, school: school }
  let!(:coach_2) { create :faculty, school: school }
  let!(:coach_3) { create :faculty, school: school }
  let!(:coach_4) { create :faculty, school: school }
  let!(:coach_5) { create :faculty, school: school_2 }
  let!(:coach_6) { create :faculty, school: school, exited: true }

  let!(:c1_level) { create :level, :one, course: course_1 }
  let!(:c2_level) { create :level, :one, course: course_2 }
  let!(:team_c1) { create :team_with_students, cohort: cohort_1 }
  let!(:team_c2) { create :team_with_students, cohort: cohort_2 }

  let!(:lone_student) { create :student, cohort: cohort_2 }

  let!(:school_admin) { create :school_admin, school: school }

  before do
    create :faculty_cohort_enrollment, faculty: coach_1, cohort: cohort_1
    create :faculty_cohort_enrollment, faculty: coach_2, cohort: cohort_1
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: coach_2,
           student: team_c1.students.first
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: coach_3,
           student: team_c2.students.first
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: coach_3,
           student: lone_student
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: coach_4,
           student: team_c2.students.first
  end

  scenario "school admin assigns faculty to a course" do
    sign_in_user school_admin.user,
                 referrer: school_course_coaches_path(course_1)

    # list all coaches
    expect(page).to have_text(coach_1.name)
    expect(page).to have_text(coach_2.name)
    expect(course_1.faculty.count).to eq(2)

    click_button "Assign Coaches to Course"

    expect(page).to have_text("No coaches selected")

    find("button[title='Select #{coach_4.name}']").click

    click_button "Select #{cohort_1.name}"
    click_button "Add Course Coaches"

    within('div[aria-label="List of course coaches"]') do
      expect(page).to have_text(coach_4.name)
    end

    expect(course_1.reload.faculty.count).to eq(3)

    open_email(coach_4.email)

    expect(current_email.subject).to include(
      "You have been added as a coach in #{course_1.name}"
    )
  end

  scenario "school admin removes a course coach" do
    sign_in_user school_admin.user,
                 referrer: school_course_coaches_path(course_1)

    expect(page).to have_text(coach_1.name)
    expect(coach_2.students.count).to eq(1)

    accept_confirm { find("button[aria-label='Delete #{coach_2.name}']").click }

    expect(page).to_not have_text(coach_2.name)
    expect(course_1.faculty.count).to eq(1)
    expect(course_1.faculty.first).to eq(coach_1)

    # Removes the coach student enrollment as well
    expect(coach_2.students.count).to eq(0)
  end

  scenario "school admin checks teams assigned to a coach and deletes them" do
    sign_in_user school_admin.user,
                 referrer: school_course_coaches_path(course_2)

    expect(page).to have_text(coach_3.name)
    find("button[aria-label='View #{coach_3.name}']").click
    expect(page).to have_text("Students assigned to coach")
    expect(page).to have_text(coach_3.email)

    expect(page).to have_text(team_c2.students.first.name)
    expect(page).to have_text(lone_student.name)

    accept_confirm { click_button "Delete #{team_c2.students.first.name}" }

    expect(page).to_not have_text(team_c2.students.first.name)

    accept_confirm { click_button "Delete #{lone_student.name}" }

    expect(page).to have_text("There are no students assigned to this coach.")
    expect(coach_3.students.count).to eq(0)
    expect(coach_3.courses.count).to eq(1)
    expect(course_2.faculty.count).to eq(2)
  end

  scenario "user who is not logged in gets redirected to sign in page" do
    visit school_course_coaches_path(course_1)
    expect(page).to have_text("Please sign in to continue.")
  end

  context "when a coach is assigned as a student coach to students in multiple courses" do
    let!(:team_c1_2) { create :team_with_students, cohort: cohort_1 }

    before do
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: coach_3,
             student: team_c1_2.students.first
    end

    scenario "user sees team assignments for coaches in the list" do
      sign_in_user school_admin.user,
                   referrer: school_course_coaches_path(course_2)

      # Check teams assigned to coach_3 in course 2
      find("button[aria-label='View #{coach_3.name}']").click
      expect(page).to have_text(team_c2.students.first.name)
      expect(page).not_to have_text(team_c1_2.students.first.name)
    end
  end

  context "when a coach has reviewed and pending submissions" do
    let!(:team_c1_2) { create :team_with_students, cohort: cohort_1 }

    let(:target_group_c1) { create :target_group, level: c1_level }
    let(:target_group_c2) { create :target_group, level: c2_level }

    let(:evaluation_criteria_c1) do
      create :evaluation_criterion, course: course_1
    end
    let(:evaluation_criteria_c2) do
      create :evaluation_criterion, course: course_2
    end

    let(:target_c1_1) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group_c1
    end
    let(:target_c1_2) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_TEAM,
             target_group: target_group_c1
    end
    let(:target_c1_3) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group_c1
    end
    let(:target_c2) do
      create :target,
             :with_shared_assignment,
             given_role: Assignment::ROLE_STUDENT,
             target_group: target_group_c2
    end

    before do
      # Make all of these targets evaluated.
      target_c1_1
        .assignments
        .first
        .evaluation_criteria << evaluation_criteria_c1
      target_c1_2
        .assignments
        .first
        .evaluation_criteria << evaluation_criteria_c1
      target_c1_3
        .assignments
        .first
        .evaluation_criteria << evaluation_criteria_c1
      target_c2.assignments.first.evaluation_criteria << evaluation_criteria_c2

      # Enroll the coach directly onto one student in this course, an another in a different course.
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: coach_1,
             student: team_c1.students.first
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: coach_1,
             student: team_c1.students.last
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: coach_1,
             student: team_c2.students.first

      # Put a few submissions in the two targets in course 1.
      first_student = team_c1.students.first
      second_student = team_c1.students.last

      complete_target(target_c1_1, first_student, evaluator: coach_1)
      complete_target(target_c1_3, first_student, evaluator: coach_1)
      submit_target(target_c1_1, second_student, evaluator: coach_1)
      complete_target(target_c1_3, second_student, evaluator: coach_1)

      # Submission graded by another coach in the same course shouldn't be counted.
      complete_target(target_c1_2, first_student, evaluator: coach_2)

      # Pending submission from another team without direct enrollment shouldn't be counted.
      submit_target(target_c1_2, team_c1_2.students.first, evaluator: coach_1)

      # A submission pending review by this coach in another course should not be counted.
      submit_target(target_c2, team_c2.students.first, evaluator: coach_1)

      # A submission reviewed by this coach in another course should not be counted.
      complete_target(target_c2, team_c2.students.second, evaluator: coach_1)
    end

    scenario "admin checks the counts of pending and reviewed submissions on an assigned coach" do
      sign_in_user school_admin.user,
                   referrer: school_course_coaches_path(course_1)

      # Check teams assigned to coach_3 in course 2
      find("button[aria-label='View #{coach_1.name}']").click

      within('div[aria-label="Reviewed Submissions"') do
        expect(page).to have_text("3")
      end

      within('div[aria-label="Pending Submissions"') do
        expect(page).to have_text("1")
      end
    end
  end
end
