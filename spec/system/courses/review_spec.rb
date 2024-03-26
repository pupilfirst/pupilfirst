require "rails_helper"

feature "Coach's review interface" do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:target_group_l1) { create :target_group, level: level_1 }
  let(:target_group_l2) { create :target_group, level: level_2 }
  let(:target_group_l3) { create :target_group, level: level_3 }
  let(:target_l1) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l1
  end
  let(:target_l2) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l2
  end
  let(:target_l3) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l3
  end
  let(:team_target) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_TEAM,
           target_group: target_group_l2
  end
  let(:auto_verify_target) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group_l1
  end
  let(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let(:evaluation_criterion_2) { create :evaluation_criterion, course: course }
  let(:student_l1) { create :student, cohort: cohort }
  let(:student_l2) { create :student, cohort: cohort }
  let(:team_l3) { create :team, cohort: cohort }
  let!(:student_l3) { create :student, cohort: cohort, team: team_l3 }
  let!(:student_l3_2) { create :student, cohort: cohort, team: team_l3 }
  let(:course_coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }
  let(:school_admin) { create :school_admin }

  before do
    # Enroll one coach as a "course" coach.
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort

    # ...and another as a directly-assigned "team" coach.
    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: team_coach,
           student: student_l3

    # Set evaluation criteria on the target so that its submissions can be reviewed.
    target_l1.assignments.first.evaluation_criteria << evaluation_criterion
    target_l2.assignments.first.evaluation_criteria << evaluation_criterion
    target_l3.assignments.first.evaluation_criteria << evaluation_criterion
    target_l3.assignments.first.evaluation_criteria << evaluation_criterion_2
    team_target.assignments.first.evaluation_criteria << evaluation_criterion
    student_l3.user.update!(email: "pupilfirst@example.com")
    student_l2.user.update!(name: "Pupilfirst Test User")
  end

  context "with multiple submissions" do
    # Create a couple of passed submissions for the team 3.
    let!(:submission_l1_t3) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_l3],
        target: target_l1,
        evaluator_id: team_coach.id,
        evaluated_at: 4.days.ago,
        passed_at: 1.day.ago
      )
    end
    let!(:submission_l2_t3) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_l3],
        target: target_l2,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: nil,
        created_at: 1.day.ago
      )
    end
    let!(:team_submission) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team_l3.students,
        target: team_target,
        evaluator_id: course_coach.id,
        evaluated_at: 1.day.ago,
        passed_at: nil,
        created_at: 2.days.ago
      )
    end
    let!(:auto_verified_submission) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team_l3.students,
        target: auto_verify_target,
        passed_at: 1.day.ago
      )
    end

    # And one passed submission for team 2.
    let!(:submission_l1_t2) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_l2],
        target: target_l1,
        evaluator_id: team_coach.id,
        evaluated_at: 3.days.ago,
        passed_at: 3.days.ago,
        created_at: 4.days.ago
      )
    end

    # Create a couple of pending submissions for the teams.
    let!(:submission_l1_t1) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        target: target_l1,
        reviewer: course_coach,
        reviewer_assigned_at: 1.day.ago,
        owners: [student_l1]
      )
    end
    let!(:submission_l2_t2) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        target: target_l2,
        owners: [student_l2],
        created_at: 1.day.ago
      )
    end
    let!(:submission_l3_t3) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        target: target_l3,
        owners: [student_l3],
        created_at: 2.days.ago
      )
    end

    # create an archived submission
    let!(:archived_submission) do
      create(
        :timeline_event,
        :with_owners,
        target: target_l1,
        owners: [student_l1],
        archived_at: 1.day.ago
      )
    end

    let!(:feedback) do
      create(
        :startup_feedback,
        faculty_id: course_coach.id,
        timeline_event: submission_l2_t3
      )
    end

    scenario "course coach visits review dashboard", js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      expect(page).to have_title("Review | #{course.name}")

      # Ensure coach is on the review dashboard.
      # Pending and Reviewed targets must be visible
      within("a[data-submission-id='#{submission_l1_t1.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text(student_l1.user.name)
      end

      within("a[data-submission-id='#{submission_l1_t3.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("Submitted by #{student_l3.user.name}")
        expect(page).to have_text("Completed")
      end

      # Archived submissions should not be visible
      expect(page).not_to have_selector(
        "a[data-submission-id='#{archived_submission.id}']"
      )

      click_link "Pending"
      expect(page).to have_content("Showing all 3 submissions")

      # All pending submissions should be listed (excluding the auto-verified one)
      expect(page).not_to have_text(auto_verify_target.title)

      within("a[data-submission-id='#{submission_l1_t1.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text(student_l1.user.name)
      end

      within("a[data-submission-id='#{submission_l2_t2.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text(student_l2.user.name)
      end

      within("a[data-submission-id='#{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
        expect(page).to have_text(student_l3.user.name)
      end

      # The 'reviewed' tab should show reviewed submissions
      click_link "Reviewed"

      within("a[data-submission-id='#{submission_l1_t3.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("Submitted by #{student_l3.user.name}")
        expect(page).to have_text("Completed")
      end

      within("a[data-submission-id='#{submission_l2_t3.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text("Submitted by #{student_l3.user.name}")
        expect(page).to have_text("Rejected")
        expect(page).to have_text("Feedback Sent")
      end

      expect(page).to have_text(team_target.title).once

      within("a[data-submission-id='#{team_submission.id}']") do
        expect(page).to have_text("Submitted by team #{team_l3.name}")
      end
    end

    scenario "course coach uses the target filter", js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      expect(page).to have_content("Showing all 7 submissions")

      # filter pending submissions
      fill_in "filter", with: "target:"
      # Check if there are not duplicate target names.
      within(".multiselect-dropdown__search-dropdown") do
        expect(page).to have_text(target_l3.title, count: 1)
      end
      # choose level 1 from the dropdown
      click_button team_target.title

      # choose level 1 submissions should be displayed

      within("div[id='submissions']") do
        expect(page).to have_text(team_target.title)
      end

      # submissions from other levels should not be displayed
      expect(page).not_to have_text(target_l1.title)
      expect(page).not_to have_text(target_l2.title)
      expect(page).not_to have_text(target_l3.title)
    end

    scenario "course coach uses the search filter", js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      expect(page).to have_content("Showing all 7 submissions")

      # Search by email
      fill_in "filter", with: "pupilfirst@example.com"
      click_button "Pick Name or Email: pupilfirst@example.com"

      within("div[id='submissions']") do
        expect(page).to have_text(student_l3.name)
      end

      expect(page).to have_text(target_l1.title)
      expect(page).to have_text(target_l2.title)
      expect(page).to have_text(target_l3.title)
      expect(page).to have_text(team_target.title)

      expect(page).to have_content("Showing all 4 submissions")

      # Search by name
      fill_in "filter", with: "Pupilfirst Test User"
      click_button "Pick Name or Email: Pupilfirst Test User"

      expect(page).to have_text(target_l1.title)
      expect(page).to have_text(target_l2.title)
      expect(page).not_to have_text(target_l3.title)
      expect(page).not_to have_text(team_target.title)

      expect(page).to have_content("Showing all 2 submissions")
    end

    scenario "team coach visits the review dashboard", js: true do
      sign_in_user team_coach.user, referrer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      click_link "Pending"

      fill_in "filter", with: "Personal coach:"
      click_button "Pick Personal Coach: Me"

      expect(page).to have_content("1")

      within("a[data-submission-id='#{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
        expect(page).to have_text(student_l3.user.name)
      end

      # submissions from other teams should not be shown
      expect(page).not_to have_text(target_l1.title)
      expect(page).not_to have_text(target_l2.title)

      # The 'reviewed' tab should show reviewed submissions
      click_link "Reviewed"

      # Target in L1 should be listed only once.
      expect(page).to have_text(target_l1.title, count: 1)

      within("a[data-submission-id='#{submission_l1_t3.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text(student_l3.user.name)
      end

      within("a[data-submission-id='#{submission_l2_t3.id}']") do
        expect(page).to have_text(target_l2.title)
        expect(page).to have_text(student_l3.user.name)
      end

      # team coach should be able to remove the filter showing only his assigned submissions.
      find('button[title="Remove selection: Me"]').click

      # Target in L1 should now be listed twice, for the submission from a non-assigned team.
      expect(page).to have_text(target_l1.title, count: 2)

      click_link "Pending"

      # The 'pending' count should update once we switch to the pending tab.
      expect(page).to have_content("Showing all 3 submissions")

      # The pending tab should list all pending submissions.
      expect(page).to have_text(target_l1.title)
      expect(page).to have_text(target_l2.title)
    end

    scenario "coach uses the assigned to filter", js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      click_link "Pending"

      fill_in "filter", with: "assigned to:"
      click_button "Pick Assigned To: Me"

      expect(page).to have_content("1")

      within("a[data-submission-id='#{submission_l1_t1.id}']") do
        expect(page).to have_text(target_l1.title)
        expect(page).to have_text(course_coach.user.name)
      end

      expect(page).not_to have_text(target_l3.title)
      expect(page).not_to have_text(target_l2.title)
      expect(page).to have_content("There's only one submission")

      find('button[title="Remove selection: Me"]').click

      expect(page).to have_text(target_l1.title)
      expect(page).to have_text(target_l2.title)
      expect(page).to have_text(target_l3.title)

      expect(page).to have_content("Showing all 3 submissions")
    end

    scenario "coach uses the reviewed by filter", js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      fill_in "filter", with: "reviewed by:"
      click_button "Pick Reviewed By: Me"

      expect(page).to have_content("Showing all 2 submissions")
      expect(page).to have_content("Status: Reviewed")
      expect(page).not_to have_text(target_l1.title)

      find('button[title="Remove selection: Me"]').click
      expect(page).to have_text(target_l1.title)
      expect(page).to have_content("Showing all 4 submissions")
    end

    context "when the course has inactive students" do
      let(:inactive_cohort) do
        create :cohort, course: course, ends_at: 1.day.ago
      end

      let!(:inactive_team) do
        create :team_with_students, cohort: inactive_cohort
      end

      before do
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          owners: inactive_team.students,
          target: team_target
        )

        create(
          :faculty_cohort_enrollment,
          faculty: course_coach,
          cohort: inactive_cohort
        )
      end

      scenario "coach can access inactive submission", js: true do
        sign_in_user course_coach.user, referrer: review_course_path(course)

        expect(page).to have_content("Showing all 7 submissions")

        # Search by email
        fill_in "filter", with: "Inactive Students"
        click_button "Pick Include: Inactive Students"

        expect(page).to have_content("Showing all 8 submissions")
        expect(page).to have_content(inactive_team.name)
      end
    end

    context "when random filters are applied" do
      let(:random_level) { create :level, :one }
      let(:random_target) do
        create :target,
               :with_shared_assignment,
               given_role: Assignment::ROLE_STUDENT
      end

      scenario "coach visits review dashboard", js: true do
        sign_in_user course_coach.user,
                     referrer:
                       review_course_path(
                         course,
                         levelId: random_level.id,
                         targetId: random_target.id
                       )

        expect(page).to have_content("Showing all 7 submissions")
        expect(page).not_to have_content(random_level.name)
        expect(page).not_to have_content(random_target.title)
      end
    end

    scenario "coach changes the sort order of submissions", js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      # Verify initial sort order
      expect(find("#submissions a:nth-child(1)")).to have_content(
        submission_l1_t1.title
      )
      expect(find("#submissions a:nth-child(2)")).to have_content(
        submission_l1_t3.title
      )
      expect(find("#submissions a:nth-child(3)")).to have_content(
        submission_l2_t3.title
      )
      expect(find("#submissions a:nth-child(4)")).to have_content(
        submission_l2_t2.title
      )
      expect(find("#submissions a:nth-child(5)")).to have_content(
        submission_l3_t3.title
      )

      # Switch to pending tab
      click_link "Pending"

      within("div[aria-label='Change submissions sorting']") do
        expect(page).to have_content("Submitted At")
      end

      # Check current ordering of pending items
      expect(find("#submissions a:nth-child(3)")).to have_content(
        submission_l1_t1.title
      )
      expect(find("#submissions a:nth-child(2)")).to have_content(
        submission_l2_t2.title
      )
      expect(find("#submissions a:nth-child(1)")).to have_content(
        submission_l3_t3.title
      )

      # Switch to all tabs to verify default ordering
      click_link "All"

      expect(find("#submissions a:nth-child(1)")).to have_content(
        submission_l1_t1.title
      )
      expect(find("#submissions a:nth-child(2)")).to have_content(
        submission_l1_t3.title
      )
      expect(find("#submissions a:nth-child(3)")).to have_content(
        submission_l2_t3.title
      )
      expect(find("#submissions a:nth-child(4)")).to have_content(
        submission_l2_t2.title
      )
      expect(find("#submissions a:nth-child(5)")).to have_content(
        submission_l3_t3.title
      )

      # Switch back to Pending tab
      click_link "Pending"

      # Swap the ordering of pending items
      click_button("toggle-sort-order")

      expect(find("#submissions a:nth-child(1)")).to have_content(
        submission_l1_t1.title
      )
      expect(find("#submissions a:nth-child(2)")).to have_content(
        submission_l2_t2.title
      )
      expect(find("#submissions a:nth-child(3)")).to have_content(
        submission_l3_t3.title
      )

      # Switch to reviewed tab and check sorting
      click_link "Reviewed"
      click_button "Reviewed At"
      click_button "Submitted At"

      expect(find("#submissions a:nth-child(1)")).to have_content(
        submission_l1_t3.title
      )
      expect(find("#submissions a:nth-child(2)")).to have_content(
        submission_l2_t3.title
      )

      click_button("toggle-sort-order")

      expect(find("#submissions a:nth-child(1)")).to have_content(
        submission_l1_t2.title
      )

      expect(find("#submissions a:nth-child(2)")).to have_content(
        team_submission.title
      )

      # Change sorting criterion in reviewed tab
      click_button "Submitted At"
      click_button "Reviewed At"

      expect(find("#submissions a:nth-child(1)")).to have_content(
        submission_l1_t3.title
      )
      expect(find("#submissions a:nth-child(2)")).to have_content(
        submission_l1_t2.title
      )

      click_button("toggle-sort-order")

      expect(find("#submissions a:nth-child(1)")).to have_content(
        team_submission.title
      )
      expect(find("#submissions a:nth-child(2)")).to have_content(
        submission_l2_t3.title
      )
    end

    scenario "coach can access submissions from review dashboard", js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      within("a[data-submission-id='#{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
      end

      click_link submission_l3_t3.title

      # submissions overlay should be visible
      expect(page).to have_text("Submission #1")
    end

    context "when there are multiple team coaches" do
      let(:team_coach_2) { create :faculty, school: school }

      before do
        create :faculty_student_enrollment,
               :with_cohort_enrollment,
               faculty: team_coach_2,
               student: student_l2
      end

      scenario "one team coach uses filter to see submissions personal coach another coach",
               js: true do
        sign_in_user team_coach.user, referrer: review_course_path(course)

        click_link "Pending"
        fill_in "filter", with: "personal coach:"
        click_button "Pick Personal Coach: Me"

        expect(page).to have_content("1")
        expect(page).to have_text(target_l3.title)
        expect(page).not_to have_text(target_l2.title)

        fill_in "filter", with: "personal coach:"
        click_button "Personal Coach: #{team_coach_2.name}"
        expect(page).to have_content("1")

        # ...but the submission has changed.
        expect(page).not_to have_text(target_l3.title)
        expect(page).to have_text(target_l2.title)

        # Similarly, the reviewed page will list a submission from the team personal coach team coach 2, but not the current coach.
        click_link "Reviewed"

        expect(page).to have_text student_l2.name
        expect(page).not_to have_text student_l3.name
      end
    end
  end

  context "when there are over 25 submissions" do
    let(:latest_submitted) do
      student_l1.timeline_events.order(created_at: :DESC).first
    end
    let(:earliest_reviewed) do
      student_l3.timeline_events.order(evaluated_at: :ASC).first
    end

    before do
      (1..30).each do |n|
        # Passed submissions
        create(
          :timeline_event,
          :with_owners,
          owners: [student_l3],
          latest: n == 1,
          target: target_l1,
          evaluator_id: course_coach.id,
          evaluated_at: n.days.ago,
          passed_at: n.days.ago,
          created_at: n.days.ago
        )
      end

      (1..10).each do |n|
        # Pending submissions with level2 target
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          target: target_l2,
          owners: [student_l1],
          created_at: n.days.ago
        )
      end

      (21..40).each do |n|
        # Pending submissions with level1 target
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          target: target_l1,
          owners: [student_l1],
          created_at: n.days.ago
        )
      end
    end

    scenario "coach browses paginated pending and reviewed submissions list",
             js: true do
      sign_in_user course_coach.user, referrer: review_course_path(course)

      # Ensure coach is on the review dashboard.
      click_link "Pending"
      expect(page).to have_content("30")
      expect(page).to have_text(target_l1.title, count: 20)

      click_button "Load More Submissions..."

      # Ensure new submissions loaded below old subimission.
      expect(find("#submissions a:nth-child(21)")).to have_content(
        target_l2.title
      )
      expect(page).to have_text(target_l2.title, count: 10)
      expect(page).not_to have_button("Load More Submissions...")

      click_link "Reviewed"

      expect(page).to have_text(target_l1.title, count: 20)

      click_button "Load More Submissions..."

      expect(page).to have_text(target_l1.title, count: 30)
      expect(page).not_to have_button("Load More Submissions...")
    end
  end

  scenario "coach visits completely empty review dashboard", js: true do
    sign_in_user course_coach.user, referrer: review_course_path(course)

    expect(page).to have_text("No submissions found")

    click_link "Pending"

    # no pending submission message should shown
    expect(page).to have_text("No submissions found")

    click_link "Reviewed"

    # no reviewed submission message should shown
    expect(page).to have_text("No submissions found")
  end

  scenario "student tries to access the review dashboard" do
    sign_in_user student_l1.user, referrer: review_course_path(course)

    expect(page).to have_text("The page you were looking for doesn't exist!")
    expect(page).not_to have_content(course.name)
  end

  context "when user is an admin" do
    # Create a couple of passed submissions for the team 3.
    let!(:submission_l1_t3) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_l3],
        target: target_l1,
        evaluator_id: team_coach.id,
        evaluated_at: 4.days.ago,
        passed_at: 1.day.ago
      )
    end
    let!(:submission_l2_t3) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_l3],
        target: target_l2,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: nil,
        created_at: 1.day.ago
      )
    end
    let!(:team_submission) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: team_l3.students,
        target: team_target,
        evaluator_id: course_coach.id,
        evaluated_at: 1.day.ago,
        passed_at: nil,
        created_at: 2.days.ago
      )
    end

    # And one passed submission for team 2.
    let!(:submission_l1_t2) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student_l2],
        target: target_l1,
        evaluator_id: team_coach.id,
        evaluated_at: 3.days.ago,
        passed_at: 3.days.ago,
        created_at: 4.days.ago
      )
    end

    # Create pending submissions for teams
    let!(:submission_l1_t1) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        target: target_l1,
        reviewer: course_coach,
        reviewer_assigned_at: 1.day.ago,
        owners: [student_l1]
      )
    end
    let!(:submission_l2_t2) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        target: target_l2,
        owners: [student_l2],
        created_at: 1.day.ago
      )
    end
    let!(:submission_l3_t3) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        target: target_l3,
        owners: [student_l3],
        created_at: 2.days.ago
      )
    end

    let!(:feedback) do
      create(
        :startup_feedback,
        faculty_id: course_coach.id,
        timeline_event: submission_l2_t3
      )
    end

    scenario "admin can view all submissions", js: true do
      sign_in_user school_admin.user, referrer: review_course_path(course)

      expect(page).to have_title("Review | #{course.name}")

      expect(page).to have_content("Showing all 7 submissions")
    end

    context "when the course has inactive students" do
      let(:inactive_cohort) do
        create :cohort, course: course, ends_at: 1.day.ago
      end

      let!(:inactive_team) do
        create :team_with_students, cohort: inactive_cohort
      end

      before do
        create(
          :timeline_event,
          :with_owners,
          latest: true,
          owners: inactive_team.students,
          target: team_target
        )

        create(
          :faculty_cohort_enrollment,
          faculty: course_coach,
          cohort: inactive_cohort
        )
      end

      scenario "admin can access inactive submissions", js: true do
        sign_in_user school_admin.user, referrer: review_course_path(course)

        expect(page).to have_content("Showing all 7 submissions")

        fill_in "filter", with: "Inactive Students"
        click_button "Pick Include: Inactive Students"

        expect(page).to have_content("Showing all 8 submissions")
        expect(page).to have_content(inactive_team.name)
      end
    end

    scenario "admin can access the review page for a submission", js: true do
      sign_in_user school_admin.user, referrer: review_course_path(course)

      within("a[data-submission-id='#{submission_l3_t3.id}']") do
        expect(page).to have_text(target_l3.title)
      end

      click_link submission_l3_t3.title

      # submissions overlay should be visible
      expect(page).to have_text("Submission #1")
    end
  end
end
