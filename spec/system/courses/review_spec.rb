require 'rails_helper'

feature 'Course review' do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:target_group_l1) { create :target_group, level: level_1 }
  let(:target_group_l2) { create :target_group, level: level_2 }
  let(:target_group_l3) { create :target_group, level: level_3 }
  let(:target_l1) { create :target, :for_founders, target_group: target_group_l1 }
  let(:target_l2) { create :target, :for_founders, target_group: target_group_l2 }
  let(:target_l3) { create :target, :for_founders, target_group: target_group_l3 }
  let(:auto_verify_target) { create :target, :for_founders, target_group: target_group_l1 }
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let(:team_l1) { create :startup, level: level_1 }
  let(:team_l2) { create :startup, level: level_2 }
  let(:team_l3) { create :startup, level: level_3 }
  let(:coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }
  let(:school_admin) { create :school_admin }

  before do
    create :faculty_course_enrollment, faculty: coach, course: course
    create :faculty_startup_enrollment, faculty: team_coach, startup: team_l3

    # Set evaluation criteria on the target so that its submissions can be reviewed.
    target_l1.evaluation_criteria << evaluation_criterion
    target_l2.evaluation_criteria << evaluation_criterion
    target_l3.evaluation_criteria << evaluation_criterion
  end

  context 'with multiple submissions' do
    # Create a couple of passed submissions for the team 3.
    let(:submission_l1_t3) { create(:timeline_event, latest: true, target: target_l1, evaluator_id: coach.id, evaluated_at: 1.day.ago, passed_at: 1.day.ago) }
    let(:submission_l2_t3) { create(:timeline_event, latest: true, target: target_l2, evaluator_id: coach.id, evaluated_at: 1.day.ago, passed_at: nil) }
    let(:auto_verified_submission) { create(:timeline_event, latest: true, target: auto_verify_target, passed_at: 1.day.ago) }

    # Create a couple of pending submissions for the teams.
    let(:submission_l1_t1) { create(:timeline_event, latest: true, target: target_l1) }
    let(:submission_l2_t2) { create(:timeline_event, latest: true, target: target_l2) }
    let(:submission_l3_t3) { create(:timeline_event, latest: true, target: target_l3) }

    let(:feedback) { create(:startup_feedback, startup_id: team_l2.id, faculty_id: coach.id) }

    before do
      submission_l1_t1.founders << team_l1.founders.first
      submission_l2_t2.founders << team_l2.founders.first
      submission_l1_t3.founders << team_l3.founders.first
      submission_l2_t3.founders << team_l3.founders.first
      submission_l3_t3.founders << team_l3.founders.first
      submission_l2_t3.startup_feedback << feedback
    end

    scenario 'coach visits review dashboard', js: true do
      sign_in_user coach.user, referer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('Pending')
        expect(page).to have_content('3')
      end

      # All pending submissions should be listed (excluding the auto-verified one)
      expect(page).not_to have_text(auto_verify_target.title)

      within("div[aria-label='pending-submission-card-#{submission_l1_t1.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("Level 1")
        expect(page).to have_text(team_l1.founders.first.user.name)
      end
      within("div[aria-label='pending-submission-card-#{submission_l2_t2.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text("Level 2")
        expect(page).to have_text(team_l2.founders.first.user.name)
      end
      within("div[aria-label='pending-submission-card-#{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
        expect(page).to have_text("Level 3")
        expect(page).to have_text(team_l3.founders.first.user.name)
      end

      # The 'reviewed' tab should show reviewed submissions
      click_button 'Reviewed'

      within("div[aria-label='reviewed-submission-card-#{submission_l1_t3.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("Level 1")
        expect(page).to have_text(team_l3.founders.first.user.name)
        expect(page).to have_text("Passed")
      end
      within("div[aria-label='reviewed-submission-card-#{submission_l2_t3.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text("Level 2")
        expect(page).to have_text(team_l3.founders.first.user.name)
        expect(page).to have_text("Failed")
        expect(page).to have_text("Feedback Sent")
      end
    end

    scenario 'coach uses the level filter', js: true do
      sign_in_user coach.user, referer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('Pending')
        expect(page).to have_content('3')
      end

      # filter pending submissions
      click_button 'All Levels'
      # choose level 1 from the dropdown
      click_button "Level 1 | #{level_1.name}"

      # choose level 1 submissions should be displayed
      expect(page).to have_text(target_l1.title)

      # submissions from other levels should not be displayed
      expect(page).not_to have_text(target_l2.title)
      expect(page).not_to have_text(target_l3.title)

      # switch level
      click_button "Level 1 | #{level_1.name}"
      click_button "Level 2 | #{level_2.name}"

      # choose level 2 submissions should be displayed
      expect(page).to have_text(target_l2.title)

      # submissions from other levels should not be displayed
      expect(page).not_to have_text(target_l1.title)
      expect(page).not_to have_text(target_l3.title)

      # filter should persist on review tab
      click_button 'Reviewed'

      expect(page).to have_text(target_l2.title)
      expect(page).not_to have_text(target_l1.title)

      # level filter should work in reviewed tab
      click_button "Level 2 | #{level_2.name}"
      click_button "Level 3 | #{level_3.name}"

      expect(page).to have_text("No Reviewed Submission")

      click_button "Level 3 | #{level_3.name}"
      click_button "Level 1 | #{level_1.name}"

      expect(page).to have_text(target_l1.title)
      expect(page).not_to have_text(target_l2.title)

      # filter should persist on pending tab
      click_button 'Pending'

      # choose level 1 submissions should be displayed
      expect(page).to have_text(target_l1.title)

      # submissions from other levels should not be displayed
      expect(page).not_to have_text(target_l2.title)
      expect(page).not_to have_text(target_l3.title)
    end

    scenario 'team coach visit review dashboard', js: true do
      sign_in_user team_coach.user, referer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('Pending')
        expect(page).to have_content('1')
      end

      within("div[aria-label='pending-submission-card-#{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
        expect(page).to have_text("Level 3")
        expect(page).to have_text(team_l3.founders.first.user.name)
      end

      # submissions from other teams should not be shown
      expect(page).not_to have_text(target_l1.title)
      expect(page).not_to have_text(target_l2.title)

      # The 'reviewed' tab should show reviewed submissions
      click_button 'Reviewed'

      within("div[aria-label='reviewed-submission-card-#{submission_l1_t3.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("Level 1")
        expect(page).to have_text(team_l3.founders.first.user.name)
      end
      within("div[aria-label='reviewed-submission-card-#{submission_l2_t3.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text("Level 2")
        expect(page).to have_text(team_l3.founders.first.user.name)
      end
    end

    scenario 'team coach visit review dashboard', js: true do
      sign_in_user coach.user, referer: review_course_path(course)

      within("div[aria-label='pending-submission-card-#{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
      end
      find("div[aria-label='pending-submission-card-#{submission_l3_t3.id}']").click
      # submissions overlay should be visible
      expect(page).to have_text('Submission #1')
    end
  end

  scenario 'without any submissions', js: true do
    sign_in_user coach.user, referer: review_course_path(course)

    # Ensure coach is on the review dashboard.
    within("div[aria-label='status-tab']") do
      expect(page).to have_content('Pending')
      expect(page).to have_content('0')
    end

    # no pending submission message should shown
    expect(page).to have_text('No pending submissions to review')

    click_button 'Reviewed'

    # no reviewed submission message should shown
    expect(page).to have_text("No Reviewed Submission")
  end

  scenario 'student tries to access the review dashboard' do
    sign_in_user team_l1.founders.first.user, referer: review_course_path(course)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(course.name)
  end

  scenario 'school admin tries to access the review dashboard' do
    sign_in_user school_admin.user, referer: review_course_path(course)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(course.name)
  end
end
