require 'rails_helper'

feature "Coach's review interface" do
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
  let(:team_target) { create :target, :for_team, target_group: target_group_l2 }
  let(:auto_verify_target) { create :target, :for_founders, target_group: target_group_l1 }
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let(:team_l1) { create :startup, level: level_1 }
  let(:team_l2) { create :startup, level: level_2 }
  let(:team_l3) { create :startup, level: level_3 }
  let(:course_coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }
  let(:school_admin) { create :school_admin }

  before do
    # Enroll one coach as a "course" coach.
    create :faculty_course_enrollment, faculty: course_coach, course: course

    # ...and another as a directly-assigned "team" coach.
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach, startup: team_l3

    # Set evaluation criteria on the target so that its submissions can be reviewed.
    target_l1.evaluation_criteria << evaluation_criterion
    target_l2.evaluation_criteria << evaluation_criterion
    target_l3.evaluation_criteria << evaluation_criterion
  end

  context 'with multiple submissions' do
    # Create a couple of passed submissions for the team 3.
    let!(:submission_l1_t3) { create(:timeline_event, :with_owners, latest: true, owners: [team_l3.founders.first], target: target_l1, evaluator_id: course_coach.id, evaluated_at: 4.days.ago, passed_at: 1.day.ago) }
    let!(:submission_l2_t3) { create(:timeline_event, :with_owners, latest: true, owners: [team_l3.founders.first], target: target_l2, evaluator_id: course_coach.id, evaluated_at: 2.days.ago, passed_at: nil, created_at: 1.day.ago) }
    let!(:team_submission) { create(:timeline_event, :with_owners, latest: true, owners: team_l3.founders, target: team_target, evaluator_id: course_coach.id, evaluated_at: 1.day.ago, passed_at: nil, created_at: 2.days.ago) }
    let!(:auto_verified_submission) { create(:timeline_event, :with_owners, latest: true, owners: team_l3.founders, target: auto_verify_target, passed_at: 1.day.ago) }

    # And one passed submission for team 2.
    let!(:submission_l1_t2) { create(:timeline_event, :with_owners, latest: true, owners: [team_l2.founders.first], target: target_l1, evaluator_id: course_coach.id, evaluated_at: 3.days.ago, passed_at: 3.days.ago, created_at: 4.days.ago) }

    # Create a couple of pending submissions for the teams.
    let!(:submission_l1_t1) { create(:timeline_event, :with_owners, latest: true, target: target_l1, owners: [team_l1.founders.first]) }
    let!(:submission_l2_t2) { create(:timeline_event, :with_owners, latest: true, target: target_l2, owners: [team_l2.founders.first], created_at: 1.day.ago) }
    let!(:submission_l3_t3) { create(:timeline_event, :with_owners, latest: true, target: target_l3, owners: [team_l3.founders.first], created_at: 2.days.ago) }

    let(:feedback) { create(:startup_feedback, startup_id: team_l2.id, faculty_id: course_coach.id) }

    before do
      submission_l2_t3.startup_feedback << feedback
    end

    scenario 'course coach visits review dashboard', js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('Pending')
        expect(page).to have_content('3')
      end

      # All pending submissions should be listed (excluding the auto-verified one)
      expect(page).not_to have_text(auto_verify_target.title)

      within("a[aria-label='Submission #{submission_l1_t1.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("Level 1")
        expect(page).to have_text(team_l1.founders.first.user.name)
      end

      within("a[aria-label='Submission #{submission_l2_t2.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text("Level 2")
        expect(page).to have_text(team_l2.founders.first.user.name)
      end

      within("a[aria-label='Submission #{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
        expect(page).to have_text("Level 3")
        expect(page).to have_text(team_l3.founders.first.user.name)
      end

      # The 'reviewed' tab should show reviewed submissions
      click_button 'Reviewed'

      within("a[aria-label='Submission #{submission_l1_t3.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("Level 1")
        expect(page).to have_text("Submitted by: #{team_l3.founders.first.user.name}")
        expect(page).to have_text("Completed")
      end

      within("a[aria-label='Submission #{submission_l2_t3.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text("Level 2")
        expect(page).to have_text("Submitted by: #{team_l3.founders.first.user.name}")
        expect(page).to have_text("Rejected")
        expect(page).to have_text("Feedback Sent")
      end

      expect(page).to have_text(team_target.title).once

      within("a[aria-label='Submission #{team_submission.id}']") do
        expect(page).to have_text("Submitted by team: #{team_l3.name}")
      end
    end

    scenario 'course coach uses the level filter', js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('Pending')
        expect(page).to have_content('3')
      end

      # filter pending submissions
      fill_in 'filter', with: 'level'
      # choose level 1 from the dropdown
      click_button "Level 1: #{level_1.name}"

      # choose level 1 submissions should be displayed
      expect(page).to have_text(target_l1.title)

      # submissions from other levels should not be displayed
      expect(page).not_to have_text(target_l2.title)
      expect(page).not_to have_text(target_l3.title)

      # switch level
      fill_in 'filter', with: 'level'
      click_button "Level 2: #{level_2.name}"

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
      fill_in 'filter', with: 'level'
      click_button "Level 3: #{level_3.name}"

      expect(page).to have_text("No submissions found")

      fill_in 'filter', with: 'level'
      click_button "Level 1: #{level_1.name}"

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

    scenario 'team coach visits the review dashboard', js: true do
      sign_in_user team_coach.user, referrer: review_course_path(course)

      expect(page).to have_text('Assigned to: Me')

      # Ensure coach is on the review dashboard.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('Pending')
        expect(page).to have_content('1')
      end

      within("a[aria-label='Submission #{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
        expect(page).to have_text("Level 3")
        expect(page).to have_text(team_l3.founders.first.user.name)
      end

      # submissions from other teams should not be shown
      expect(page).not_to have_text(target_l1.title)
      expect(page).not_to have_text(target_l2.title)

      # The 'reviewed' tab should show reviewed submissions
      click_button 'Reviewed'

      # Target in L1 should be listed only once.
      expect(page).to have_text(target_l1.title, count: 1)

      within("a[aria-label='Submission #{submission_l1_t3.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("Level 1")
        expect(page).to have_text(team_l3.founders.first.user.name)
      end

      within("a[aria-label='Submission #{submission_l2_t3.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text("Level 2")
        expect(page).to have_text(team_l3.founders.first.user.name)
      end

      # team coach should be able to remove the filter showing only his assigned submissions.
      find('button[title="Remove selection: Me"]').click

      expect(page).to have_text('Now showing submissions from all students in this course')

      # Target in L1 should now be listed twice, for the submission from a non-assigned team.
      expect(page).to have_text(target_l1.title, count: 2)

      click_button 'Pending'

      # The 'pending' count should update once we switch to the pending tab.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('3')
      end

      # The pending tab should list all pending submissions.
      expect(page).to have_text(target_l1.title)
      expect(page).to have_text(target_l2.title)

      # There should be an option to restore the 'assigned to me' filter.
      click_button 'Assigned to: Me'

      # ...which restores the page to original state.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('1')
      end
    end

    scenario 'coach changes the sort order of submissions', js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      within("div[aria-label='Change submissions sorting']") do
        expect(page).to have_content("Submitted At")
      end

      # Check current ordering of pending items
      expect(find("#submissions a:nth-child(3)")).to have_content(submission_l1_t1.title)
      expect(find("#submissions a:nth-child(2)")).to have_content(submission_l2_t2.title)
      expect(find("#submissions a:nth-child(1)")).to have_content(submission_l3_t3.title)

      # Swap the ordering of pending items
      click_button('toggle-sort-order')

      expect(find("#submissions a:nth-child(1)")).to have_content(submission_l1_t1.title)
      expect(find("#submissions a:nth-child(2)")).to have_content(submission_l2_t2.title)
      expect(find("#submissions a:nth-child(3)")).to have_content(submission_l3_t3.title)

      # Switch to reviewed tab and check sorting
      click_button 'Reviewed'

      expect(find("#submissions a:nth-child(1)")).to have_content(submission_l1_t3.title)
      expect(find("#submissions a:nth-child(2)")).to have_content(submission_l2_t3.title)

      click_button('toggle-sort-order')

      expect(find("#submissions a:nth-child(1)")).to have_content(submission_l1_t2.title)
      expect(find("#submissions a:nth-child(2)")).to have_content(team_submission.title)

      # Change sorting criterion in reviewed tab
      click_button 'Submitted At'
      click_button 'Reviewed At'

      expect(find("#submissions a:nth-child(1)")).to have_content(submission_l1_t3.title)
      expect(find("#submissions a:nth-child(2)")).to have_content(submission_l1_t2.title)

      click_button('toggle-sort-order')

      expect(find("#submissions a:nth-child(1)")).to have_content(team_submission.title)
      expect(find("#submissions a:nth-child(2)")).to have_content(submission_l2_t3.title)
    end

    scenario 'coach can access submissions from review dashboard', js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      within("a[aria-label='Submission #{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
      end

      click_link submission_l3_t3.title

      # submissions overlay should be visible
      expect(page).to have_text('Submission #1')
    end

    context 'when there are multiple team coaches' do
      let(:team_coach_2) { create :faculty, school: school }

      before do
        create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach_2, startup: team_l2
      end

      scenario 'one team coach uses filter to see submissions assigned to another coach', js: true do
        sign_in_user team_coach.user, referrer: review_course_path(course)

        expect(page).to have_text('Assigned to: Me')

        within("div[aria-label='status-tab']") do
          expect(page).to have_content('Pending')
          expect(page).to have_content('1')
        end

        expect(page).to have_text(target_l3.title)
        expect(page).not_to have_text(target_l2.title)

        fill_in 'filter', with: 'assigned'
        click_button "Assigned to: #{team_coach_2.name}"

        # Pending count is still one.
        within("div[aria-label='status-tab']") do
          expect(page).to have_content('1')
        end

        # ...but the submission has changed.
        expect(page).not_to have_text(target_l3.title)
        expect(page).to have_text(target_l2.title)

        # Similarly, the reviewed page will list a submission from the team assigned to team coach 2, but not the current coach.
        click_button 'Reviewed'

        expect(page).to have_text team_l2.founders.first.name
        expect(page).not_to have_text team_l3.founders.first.name
      end
    end
  end

  context 'when there are over 25 submissions' do
    let(:student_l1) { team_l1.founders.first }
    let(:student_l3) { team_l3.founders.first }
    let(:latest_submitted) { student_l1.timeline_events.order(created_at: :DESC).first }
    let(:earliest_reviewed) { student_l3.timeline_events.order(evaluated_at: :ASC).first }

    before do
      (1..30).each do |n|
        # Passed submissions
        create(:timeline_event, :with_owners, owners: [student_l3], latest: n == 1, target: target_l1, evaluator_id: course_coach.id, evaluated_at: n.days.ago, passed_at: n.days.ago, created_at: n.days.ago)

        # Pending submissions
        create(:timeline_event, :with_owners, latest: true, target: target_l1, owners: [student_l1], created_at: n.days.ago)
      end
    end

    scenario 'coach browses paginated pending and reviewed submissions list', js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      within("div[aria-label='status-tab']") do
        expect(page).to have_content('Pending')
        expect(page).to have_content('30')
      end

      expect(page).to have_text(target_l1.title, count: 20)

      click_button 'Load More...'

      expect(page).to have_text(target_l1.title, count: 30)
      expect(page).not_to have_button('Load more...')
      expect(find("#submissions a:last-child")['href']).to end_with("/submissions/#{latest_submitted.id}/review")

      click_button 'Reviewed'

      expect(page).to have_text(target_l1.title, count: 20)

      click_button 'Load More...'

      expect(page).to have_text(target_l1.title, count: 30)
      expect(page).not_to have_button('Load more...')
      expect(find("#submissions a:last-child")['href']).to end_with("/submissions/#{earliest_reviewed.id}/review")
    end
  end

  scenario 'coach visits completely empty review dashboard', js: true do
    sign_in_user course_coach.user, referrer: review_course_path(course)

    # Ensure coach is on the review dashboard.
    within("div[aria-label='status-tab']") do
      expect(page).to have_content('Pending')
      expect(page).to have_content('0')
    end

    # no pending submission message should shown
    expect(page).to have_text('No submissions found')

    click_button 'Reviewed'

    # no reviewed submission message should shown
    expect(page).to have_text('No submissions found')
  end

  scenario 'student tries to access the review dashboard' do
    sign_in_user team_l1.founders.first.user, referrer: review_course_path(course)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(course.name)
  end

  scenario 'school admin tries to access the review dashboard' do
    sign_in_user school_admin.user, referrer: review_course_path(course)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(course.name)
  end
end
