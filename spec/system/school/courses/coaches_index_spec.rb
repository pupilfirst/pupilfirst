require 'rails_helper'

feature 'Course Coaches Index', js: true do
  include UserSpecHelper
  include SubmissionsHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:school_2) { create :school }
  let!(:course_1) { create :course, school: school }
  let!(:course_2) { create :course, school: school }

  let!(:coach_1) { create :faculty, school: school }
  let!(:coach_2) { create :faculty, school: school }
  let!(:coach_3) { create :faculty, school: school }
  let!(:coach_4) { create :faculty, school: school }
  let!(:coach_5) { create :faculty, school: school_2 }
  let!(:coach_6) { create :faculty, school: school, exited: true }

  let!(:c1_level) { create :level, course: course_1 }
  let!(:c2_level) { create :level, course: course_2 }
  let!(:startup_c1) { create :startup, level: c1_level }
  let!(:startup_c2) { create :startup, level: c2_level }

  let(:team_with_one_student) { create :team, level: c2_level }
  let!(:lone_student) { create :founder, startup: team_with_one_student }

  let!(:school_admin) { create :school_admin, school: school }

  before do
    create :faculty_course_enrollment, faculty: coach_1, course: course_1
    create :faculty_course_enrollment, faculty: coach_2, course: course_1
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_2, startup: startup_c1
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_3, startup: startup_c2
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_3, startup: team_with_one_student
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_4, startup: startup_c2
  end

  scenario 'school admin assigns faculty to a course' do
    sign_in_user school_admin.user, referrer: school_course_coaches_path(course_1)

    # list all coaches
    expect(page).to have_text(coach_1.name)
    expect(page).to have_text(coach_2.name)
    expect(course_1.faculty.count).to eq(2)

    click_button 'Assign Coaches to Course'

    expect(page).to have_text('No coaches selected')

    find("div[title='Select #{coach_4.name}']").click

    click_button 'Add Course Coaches'

    within('div[aria-label="List of course coaches"]') do
      expect(page).to have_text(coach_4.name)
    end

    expect(course_1.reload.faculty.count).to eq(3)

    open_email(coach_4.email)

    expect(current_email.subject).to include("You have been added as a coach in #{course_1.name}")
    expect(current_email.body).to have_link("Sign in to Review Course")
  end

  scenario 'school admin removes a course coach' do
    sign_in_user school_admin.user, referrer: school_course_coaches_path(course_1)

    expect(page).to have_text(coach_1.name)
    expect(coach_2.startups.count).to eq(1)

    accept_confirm do
      find("div[aria-label='Delete #{coach_2.name}']").click
    end

    expect(page).to_not have_text(coach_2.name)
    expect(course_1.faculty.count).to eq(1)
    expect(course_1.faculty.first).to eq(coach_1)
    # Removes the coach team enrollment as well
    expect(coach_2.startups.count).to eq(0)
  end

  scenario 'school admin checks teams assigned to a coach and deletes them' do
    sign_in_user school_admin.user, referrer: school_course_coaches_path(course_2)

    expect(page).to have_text(coach_3.name)
    find("div[aria-label='coach-card-#{coach_3.id}']").click
    expect(page).to have_text('Students assigned to coach')
    expect(page).to have_text(coach_3.email)

    within("div[aria-label='Team #{startup_c2.name}']") do
      expect(page).to have_text(startup_c2.founders.first.name)
      expect(page).to have_text(startup_c2.founders.last.name)
      expect(page).to have_text(startup_c2.name)
    end

    within("div[aria-label='Team #{team_with_one_student.name}']") do
      expect(page).to have_text(lone_student.name)
      expect(page).to_not have_text(team_with_one_student.name)
    end

    accept_confirm do
      click_button "Delete #{startup_c2.name}"
    end

    expect(page).to_not have_text(startup_c2.name)

    accept_confirm do
      click_button "Delete #{team_with_one_student.name}"
    end

    expect(page).to have_text('There are no students assigned to this coach.')
    expect(coach_3.startups.count).to eq(0)
    expect(coach_3.courses.count).to eq(1)
    expect(course_2.faculty.count).to eq(2)
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit school_course_coaches_path(course_1)
    expect(page).to have_text("Please sign in to continue.")
  end

  context 'when a coach is assigned as a team coach to students in multiple courses' do
    let!(:startup_c1_2) { create :startup, level: c1_level }

    before do
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_3, startup: startup_c1_2
    end

    scenario 'user sees team assignments for coaches in the list' do
      sign_in_user school_admin.user, referrer: school_course_coaches_path(course_2)

      # Check teams assigned to coach_3 in course 2
      find("div[aria-label='coach-card-#{coach_3.id}']").click
      expect(page).to have_text(startup_c2.name)
      expect(page).not_to have_text(startup_c1_2.name)
    end
  end

  context 'when a coach has reviewed and pending submissions' do
    let(:startup_c1_2) { create :startup, level: c1_level }

    let(:target_group_c1) { create :target_group, level: c1_level }
    let(:target_group_c2) { create :target_group, level: c2_level }

    let(:evaluation_criteria_c1) { create :evaluation_criterion, course: course_1 }
    let(:evaluation_criteria_c2) { create :evaluation_criterion, course: course_2 }

    let(:target_c1_1) { create :target, :for_founders, target_group: target_group_c1 }
    let(:target_c1_2) { create :target, :for_team, target_group: target_group_c1 }
    let(:target_c1_3) { create :target, :for_founders, target_group: target_group_c1 }
    let(:target_c2) { create :target, :for_founders, target_group: target_group_c2 }

    before do
      # Make all of these targets evaluated.
      target_c1_1.evaluation_criteria << evaluation_criteria_c1
      target_c1_2.evaluation_criteria << evaluation_criteria_c1
      target_c1_3.evaluation_criteria << evaluation_criteria_c1
      target_c2.evaluation_criteria << evaluation_criteria_c2

      # Enroll the coach directly onto one startup in this course, an another in a different course.
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_1, startup: startup_c1
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_1, startup: startup_c2

      # Put a few submissions in the two targets in course 1.
      first_student = startup_c1.founders.first
      second_student = startup_c1.founders.last

      complete_target(target_c1_1, first_student, evaluator: coach_1)
      complete_target(target_c1_3, first_student, evaluator: coach_1)
      submit_target(target_c1_1, second_student, evaluator: coach_1)
      complete_target(target_c1_3, second_student, evaluator: coach_1)

      # Submission graded by another coach in the same course shouldn't be counted.
      complete_target(target_c1_2, first_student, evaluator: coach_2)

      # Pending submission from another team without direct enrollment shouldn't be counted.
      submit_target(target_c1_2, startup_c1_2.founders.first, evaluator: coach_1)

      # A submission pending review by this coach in another course should not be counted.
      submit_target(target_c2, startup_c2.founders.first, evaluator: coach_1)

      # A submission reviewed by this coach in another course should not be counted.
      complete_target(target_c2, startup_c2.founders.second, evaluator: coach_1)
    end

    scenario 'admin checks the counts of pending and reviewed submissions on an assigned coach' do
      sign_in_user school_admin.user, referrer: school_course_coaches_path(course_1)

      # Check teams assigned to coach_3 in course 2
      find("div[aria-label='coach-card-#{coach_1.id}']").click

      within('div[aria-label="Reviewed Submissions"') do
        expect(page).to have_text('3')
      end

      within('div[aria-label="Pending Submissions"') do
        expect(page).to have_text('1')
      end
    end
  end
end
