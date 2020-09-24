require 'rails_helper'

feature 'Students view performance report and submissions overview', js: true do
  include UserSpecHelper
  include NotificationHelper

  # The basics
  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:course_coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }
  let(:coach_without_access) { create :faculty, school: school }

  # Create a team
  let!(:team) { create :startup, level: level_3 }

  # Pick a student from the team who would check his report.
  let(:student) { team.founders.first }

  # Create few targets for the student
  let(:target_group_l1) { create :target_group, level: level_1, milestone: true }
  let(:target_group_l2) { create :target_group, level: level_2, milestone: true }
  let(:target_group_l3) { create :target_group, level: level_3, milestone: true }

  let(:target_l1) { create :target, :for_founders, target_group: target_group_l1 }
  let(:target_l2) { create :target, :for_founders, target_group: target_group_l2 }
  let(:target_l3) { create :target, :for_founders, target_group: target_group_l3 }
  let!(:target_4) { create :target, :for_founders, target_group: target_group_l3 }
  let(:quiz_target_1) { create :target, :for_founders, target_group: target_group_l1 }
  let(:quiz_target_2) { create :target, :for_founders, target_group: target_group_l3 }

  # Create evaluation criteria for targets
  let(:evaluation_criterion_1) { create :evaluation_criterion, course: course }
  let(:evaluation_criterion_2) { create :evaluation_criterion, course: course }

  # Create submissions for relevant targets
  let!(:submission_target_l1_1) { create(:timeline_event, :with_owners, latest: true, owners: [student], target: target_l1, evaluator_id: course_coach.id, evaluated_at: 2.days.ago, passed_at: 3.days.ago) }
  let!(:submission_target_l1_2) { create(:timeline_event, founders: [student], target: target_l2, evaluator_id: course_coach.id, evaluated_at: 3.days.ago, passed_at: nil) }
  let!(:submission_target_l2) { create(:timeline_event, :with_owners, latest: true, owners: [student], target: target_l2, evaluator_id: course_coach.id, evaluated_at: 1.day.ago, passed_at: 1.day.ago) }
  let!(:submission_target_l3) { create(:timeline_event, founders: [student], target: target_l3, evaluator_id: course_coach.id, evaluated_at: 1.day.ago, passed_at: 1.day.ago) }
  let!(:pending_submission_target_l3) { create(:timeline_event, :with_owners, latest: true, owners: [student], target: target_l3) }
  let!(:submission_quiz_target_1) { create(:timeline_event, :with_owners, latest: true, owners: [student], target: quiz_target_1, passed_at: 1.day.ago, quiz_score: '1/3') }
  let!(:submission_quiz_target_2) { create(:timeline_event, :with_owners, latest: true, owners: [student], target: quiz_target_2, passed_at: 1.day.ago, quiz_score: '3/5') }
  let!(:coach_note_1) { create :coach_note, author: course_coach.user, student: student }
  let!(:coach_note_2) { create :coach_note, author: team_coach.user, student: student }

  before do
    create :faculty_course_enrollment, faculty: course_coach, course: course
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach, startup: team

    target_l1.evaluation_criteria << evaluation_criterion_1
    target_l2.evaluation_criteria << [evaluation_criterion_1, evaluation_criterion_2]
    target_l3.evaluation_criteria << evaluation_criterion_2
    target_4.evaluation_criteria << evaluation_criterion_2

    submission_target_l1_2.timeline_event_grades.create!(evaluation_criterion: evaluation_criterion_1, grade: 1)
    submission_target_l1_1.timeline_event_grades.create!(evaluation_criterion: evaluation_criterion_1, grade: 2)

    submission_target_l2.timeline_event_grades.create!(evaluation_criterion: evaluation_criterion_1, grade: 3)
    submission_target_l2.timeline_event_grades.create!(evaluation_criterion: evaluation_criterion_2, grade: 2)
    submission_target_l3.timeline_event_grades.create!(evaluation_criterion: evaluation_criterion_2, grade: 2)
  end

  around do |example|
    Time.use_zone(student.user.time_zone) { example.run }
  end

  scenario 'student visits course report link' do
    sign_in_user student.user, referrer: report_course_path(course)

    expect(page).to have_text('Level Progress')
    expect(page).to have_selector('.courses-report-overview__student-level', count: course.levels.where.not(number: 0).count)

    # Targets Overview
    expect(page).to have_text('Targets Overview')

    within("div[aria-label='target-completion-status']") do
      expect(page).to have_content('Incomplete: 1')
      expect(page).to have_content('Pending Review: 1')
      expect(page).to have_content('Completed: 4')
      expect(page).to have_content('66%')
    end

    within("div[aria-label='quiz-performance-chart']") do
      expect(page).to have_content('Average Quiz Score')
      expect(page).to have_content('46%')
      expect(page).to have_content('2 Quizzes Attempted')
    end

    # Average Grades
    expect(page).to have_text('Average Grades')

    within("div[aria-label='average-grade-for-criterion-#{evaluation_criterion_1.id}']") do
      expect(page).to have_content(evaluation_criterion_1.name)
      expect(page).to have_content('2.5/3')
    end

    within("div[aria-label='average-grade-for-criterion-#{evaluation_criterion_2.id}']") do
      expect(page).to have_content(evaluation_criterion_2.name)
      expect(page).to have_content('2/3')
    end

    # Coaches assigned to student
    expect(page).to have_content('Personal Coaches')
    expect(page).to have_content(team_coach.name)
    expect(page).to_not have_content(course_coach.name)

    # Checks submissions
    click_button 'Submissions'

    expect(page).to have_link(target_l1.title, href: "/targets/#{target_l1.id}")
    expect(page).to_not have_content(target_4.title)

    # Filter submissions by level
    fill_in 'filter', with: 'level'
    click_button "Level 2: #{level_2.name}"

    expect(page).not_to have_text(target_l1.title)
    expect(page).to have_link(target_l2.title, href: "/targets/#{target_l2.id}")

    # Clear the level filter
    find("button[title='Remove selection: #{level_2.name}']").click

    # Filter submissions by target status
    fill_in 'filter', with: 'status'
    click_button 'Status: Pending Review'

    expect(page).not_to have_text(target_l1.title)
    expect(page).to have_link(target_l3.title, href: "/targets/#{target_l3.id}")
  end

  scenario 'student loads more submissions' do
    # Create over 20 reviewed submissions
    20.times do
      submission = create(:timeline_event, :with_owners, latest: true, owners: [student], target: target_4, evaluator_id: course_coach.id, evaluated_at: 2.days.ago, passed_at: 3.days.ago)
      submission.timeline_event_grades.create!(evaluation_criterion: evaluation_criterion_2, grade: 2)
    end

    sign_in_user student.user, referrer: report_course_path(course)
    expect(page).to have_text('Targets Overview')
    click_button 'Submissions'
    expect(page).to have_button('Load More...')
    click_button('Load More...')

    total_submissions = student.timeline_events.evaluated_by_faculty.count + student.timeline_events.pending_review.count

    within("div[aria-label='student-submissions']") do
      expect(page).to have_selector('a', count: total_submissions)
    end

    # Switching tabs should preserve already loaded submissions
    click_button 'Overview'
    click_button 'Submissions'

    within("div[aria-label='student-submissions']") do
      expect(page).to have_selector('a', count: total_submissions)
    end
  end

  context "student's team members change mid-way of course" do
    let(:target_l1) { create :target, :for_team, target_group: target_group_l1 }
    let!(:submission_target_l1_1) { create(:timeline_event, :with_owners, latest: true, owners: team.founders, target: target_l1, evaluator_id: course_coach.id, evaluated_at: 2.days.ago, passed_at: 3.days.ago) }

    before do
      # Add a team member to student's team
      create :founder, startup: team
    end

    scenario 'submissions by old team has info on effect of team change' do
      sign_in_user student.user, referrer: report_course_path(course)

      # Switch to submissions tab
      click_button 'Submissions'

      # The main link should point to the "backup" submission page.
      expect(page).to have_link(target_l1.title, href: "/submissions/#{submission_target_l1_1.id}")

      within("div[aria-label='Team change notice for submission #{submission_target_l1_1.id}']") do
        expect(page).to have_content("This submission is not considered towards its target's completion")

        # There should be an additional link to the target as well.
        expect(page).to have_link('View Target', href: "/targets/#{target_l1.id}")
      end
    end
  end

  context 'course has targets in level zero' do
    let!(:level_0) { create :level, :zero, course: course }
    let!(:target_group_l0) { create :target_group, level: level_0 }
    let!(:target_l0) { create :target, :for_founders, target_group: target_group_l0 }

    scenario 'checks status of total targets completed in report' do
      sign_in_user student.user, referrer: report_course_path(course)

      # Check that level zero targets are not counted in the targets overview
      within("div[aria-label='target-completion-status']") do
        expect(page).to have_content('66%')
        expect(page).to have_content('Incomplete: 1')
        expect(page).to have_content('Pending Review: 1')
        expect(page).to have_content('Completed: 4')
      end
    end
  end

  context 'course has archived targets' do
    let!(:target_4) { create :target, :for_founders, :archived, target_group: target_group_l3 }
    # Archive target with verified submission for the student
    let(:target_l3) { create :target, :for_founders, :archived, target_group: target_group_l3 }

    scenario 'checks status of total targets completed in report' do
      sign_in_user student.user, referrer: report_course_path(course)

      # Check that level zero targets are not counted in the targets overview
      within("div[aria-label='target-completion-status']") do
        expect(page).to have_content('100%')
        expect(page).to have_content('Incomplete: 0')
        expect(page).to have_content('Pending Review: 0')
        expect(page).to have_content('Completed: 4')
      end
    end
  end
end
