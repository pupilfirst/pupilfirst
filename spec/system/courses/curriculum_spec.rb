require "rails_helper"

feature "Student's view of Course Curriculum", js: true do
  include NotificationHelper
  include UserSpecHelper
  include MarkdownEditorHelper

  # The basics.
  let(:course) { create :course }
  let(:cohort) { create :cohort, course: course }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:student) { create :student, cohort: cohort }
  let(:faculty) { create :faculty }

  # Levels.
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:level_3) { create :level, :three, course: course }
  let!(:level_4) { create :level, :four, course: course }
  let!(:level_5) { create :level, :five, course: course }
  let!(:locked_level_6) do
    create :level, :six, course: course, unlock_at: 1.month.from_now
  end

  # Target group we're interested in. Create milestone
  let!(:target_group_l1) { create :target_group, level: level_1 }
  let!(:target_group_l2) { create :target_group, level: level_2 }
  let!(:target_group_l3) { create :target_group, level: level_3 }
  let!(:target_group_l4_1) { create :target_group, level: level_4 }
  let!(:target_group_l4_2) { create :target_group, level: level_4 }
  let!(:target_group_l5) { create :target_group, level: level_5 }
  let!(:target_group_l6) { create :target_group, level: locked_level_6 }

  # Individual targets of different types.
  let!(:completed_target_l1) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l1,
           given_role: Assignment::ROLE_TEAM
  end
  let!(:completed_target_l1_version) { create(:target_version, target: completed_target_l1) }
  let!(:completed_target_l2) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l2,
           given_role: Assignment::ROLE_TEAM
  end
  let!(:completed_target_l3) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l3,
           given_role: Assignment::ROLE_TEAM
  end
  let!(:completed_target_l4) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l4_1,
           given_role: Assignment::ROLE_TEAM,
           given_evaluation_criteria: [evaluation_criterion]
  end
  let!(:pending_target_g1) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l4_1,
           given_role: Assignment::ROLE_TEAM
  end
  let!(:pending_target_g2) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l4_2,
           given_role: Assignment::ROLE_TEAM
  end
  let!(:submitted_target) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l4_1,
           given_role: Assignment::ROLE_TEAM,
           given_evaluation_criteria: [evaluation_criterion]
  end
  let!(:failed_target) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l4_1,
           given_role: Assignment::ROLE_TEAM,
           given_evaluation_criteria: [evaluation_criterion]
  end
  let!(:target_with_prerequisites) do
    create :target, target_group: target_group_l4_1
  end
  let!(:assignment_target_with_prerequisites) do
    create :assignment,
           :with_default_checklist,
           target: target_with_prerequisites,
           prerequisite_assignments: [pending_target_g1.assignments.first],
           role: Assignment::ROLE_TEAM
  end
  let!(:l5_reviewed_target) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l5,
           given_role: Assignment::ROLE_TEAM,
           given_evaluation_criteria: [evaluation_criterion]
  end
  let!(:l5_reviewed_target_version) { create(:target_version, target: l5_reviewed_target) }
  let!(:l5_non_reviewed_target) do
    create :target,
           :with_shared_assignment,
           :with_markdown,
           target_group: target_group_l5,
           given_role: Assignment::ROLE_TEAM
  end
  let!(:l5_non_reviewed_target_with_prerequisite) do
    create :target, :with_markdown, target_group: target_group_l5
  end
  let!(:assignment_l5_non_reviewed_target_with_prerequisite) do
    create :assignment,
           :with_default_checklist,
           target: l5_non_reviewed_target_with_prerequisite,
           role: Assignment::ROLE_TEAM,
           prerequisite_assignments: [l5_non_reviewed_target.assignments.first]
  end
  let!(:level_6_target) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l6,
           given_role: Assignment::ROLE_TEAM
  end
  let!(:level_6_draft_target) do
    create :target,
           :with_shared_assignment,
           :draft,
           target_group: target_group_l6,
           given_role: Assignment::ROLE_TEAM
  end

  # Submissions
  let!(:submission_completed_target_l1) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: completed_target_l1,
      passed_at: 1.day.ago
    )
  end
  let!(:submission_completed_target_l2) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: completed_target_l2,
      passed_at: 1.day.ago
    )
  end
  let!(:submission_completed_target_l3) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: completed_target_l3,
      passed_at: 1.day.ago
    )
  end
  let!(:submission_completed_target_l4) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: completed_target_l4,
      passed_at: 1.day.ago,
      evaluator: faculty,
      evaluated_at: 1.day.ago
    )
  end
  let!(:submission_submitted_target) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: submitted_target
    )
  end
  let!(:submission_failed_target) do
    create(
      :timeline_event,
      :with_owners,
      latest: true,
      owners: [student],
      target: failed_target,
      evaluator: faculty,
      evaluated_at: Time.zone.now
    )
  end

  before do
    # Grading for graded targets
    create(
      :timeline_event_grade,
      timeline_event: submission_completed_target_l4,
      evaluation_criterion: evaluation_criterion,
      grade: 2
    )
    create(
      :timeline_event_grade,
      timeline_event: submission_failed_target,
      evaluation_criterion: evaluation_criterion,
      grade: 1
    )
  end

  around { |example| Time.use_zone(student.user.time_zone) { example.run } }

  scenario "student who has dropped out attempts to view a course's curriculum" do
    student.update!(dropped_out_at: 1.day.ago)
    sign_in_user student.user, referrer: curriculum_course_path(course)
    expect(page).to have_content("The page you were looking for doesn't exist!")
  end

  scenario "student attempts to view an archived course's curriculum" do
    course.update!(archived_at: 1.day.ago)
    sign_in_user student.user, referrer: curriculum_course_path(course)
    expect(page).to have_content("The page you were looking for doesn't exist!")
  end

  context "when the course the student belongs has ended" do
    let!(:cohort) { create :cohort, course: course, ends_at: 1.day.ago }

    scenario "student visits the course curriculum page" do
      sign_in_user student.user, referrer: curriculum_course_path(course)
      expect(page).to have_text(
        "The course has ended and submissions are disabled for all targets!"
      )
    end
  end

  context "when a student's access to a course has ended" do
    let!(:cohort) { create :cohort, course: course, ends_at: 1.day.ago }
    let!(:another_cohort) { create :cohort, course: course }

    scenario "student visits the course curriculum page" do
      sign_in_user student.user, referrer: curriculum_course_path(course)
      expect(page).to have_text(
        "You have only limited access to the course now. You are allowed preview the content but cannot complete any target."
      )
    end
  end

  scenario "student visits the course curriculum page" do
    sign_in_user student.user, referrer: curriculum_course_path(course)

    # Course name should be displayed.
    expect(page).to have_content(course.name)

    # It should be at the fourth level.
    expect(page).to have_content(target_group_l4_1.name)
    expect(page).to have_content(target_group_l4_1.description)

    # All targets should be listed.
    expect(page).to have_content(completed_target_l4.title)
    expect(page).to have_content(pending_target_g1.title)
    expect(page).to have_content(submitted_target.title)
    expect(page).to have_content(failed_target.title)
    expect(page).to have_content(target_with_prerequisites.title)
    expect(page).to have_content(pending_target_g2.title)

    # All targets should have the right status written next to their titles.
    within("a[data-target-id='#{completed_target_l4.id}']") do
      expect(page).to have_content("Completed")
    end

    within("a[data-target-id='#{submitted_target.id}']") do
      expect(page).to have_content("Pending Review")
    end

    within("a[data-target-id='#{failed_target.id}']") do
      expect(page).to have_content("Rejected")
    end

    within("a[data-target-id='#{target_with_prerequisites.id}']") do
      expect(page).to have_content("Locked")
    end

    expect(page).to have_content(target_group_l4_1.name)
    expect(page).to have_content(target_group_l4_1.description)

    # There should only be two target groups...
    expect(page).to have_selector(".curriculum__target-group", count: 2)

    # Open the level selector dropdown.
    click_button "L4: #{level_4.name}"

    # All levels should be included in the dropdown.
    [level_1, level_2, level_3, level_5, locked_level_6].each do |l|
      expect(page).to have_text("L#{l.number}: #{l.name}")
    end

    # Select another level and check if the correct data is displayed.
    click_button "L2: #{level_2.name}"

    expect(page).to have_content(target_group_l2.name)
    expect(page).to have_content(target_group_l2.description)
    expect(page).to have_content(completed_target_l2.title)

    within("a[data-target-id='#{completed_target_l2.id}']") do
      expect(page).to have_content("Completed")
    end
  end

  scenario "student attempts target that have prerequisites" do
    sign_in_user student.user, referrer: curriculum_course_path(course)

    # Switch to Level 5.
    click_button "L4: #{level_4.name}"
    click_button "L5: #{level_5.name}"

    expect(page).to have_text(target_group_l5.name)
    expect(page).to have_text(target_group_l5.description)

    # There should be one locked target in L5 right now (target_with_prerequisites).
    expect(page).to have_selector(
      ".curriculum__target-status--locked",
      count: 1
    )

    # Non-reviewed targets that have prerequisites must be locked.
    click_link l5_non_reviewed_target_with_prerequisite.title

    expect(page).to have_text(
      "This target has prerequisites that are incomplete."
    )
    expect(page).to have_link(l5_non_reviewed_target.title)

    click_button "Close"

    # Non-reviewed targets that do not have prerequisites should be unlocked for completion.
    click_link l5_non_reviewed_target.title
    find(".course-overlay__body-tab-item", text: "Submit Form").click
    replace_markdown Faker::Lorem.sentence
    click_button "Submit"

    dismiss_notification
    click_button "Close"

    # Completing the prerequisite should unlock the previously locked non-reviewed target.
    expect(page).to have_selector(
      ".curriculum__target-status--locked",
      count: 0
    )

    click_link l5_non_reviewed_target_with_prerequisite.title

    expect(page).not_to have_text(
      "This target has prerequisites that are incomplete."
    )
    expect(page).to have_button "Submit"

    click_button "Close"
  end

  scenario "student opens a locked level" do
    sign_in_user student.user, referrer: curriculum_course_path(course)

    # Switch to the locked Level 6.
    click_button "L4: #{level_4.name}"
    click_button "L6: #{locked_level_6.name}"

    # Ensure level 6 is displayed as locked. - the content should not be visible.
    expect(page).to have_text("The level is currently locked!")
    expect(page).to have_text("You can access the content on")
    expect(page).not_to have_text(target_group_l6.name)
    expect(page).not_to have_text(target_group_l6.description)
    expect(page).not_to have_text(level_6_target.title)
  end

  scenario "student navigates between levels using the quick navigation links" do
    sign_in_user student.user, referrer: curriculum_course_path(course)

    expect(page).to have_button("L4: #{level_4.name}")

    click_button "Next Level"

    expect(page).to have_button("L5: #{level_5.name}")

    click_button "Next Level"

    expect(page).to have_button("L6: #{locked_level_6.name}")
    expect(page).not_to have_button("Next Level")

    click_button "Previous Level"
    click_button "L5: #{level_5.name}"
    click_button "L2: #{level_2.name}"
    click_button "Previous Level"

    expect(page).to have_button("L1: #{level_1.name}")
    expect(page).not_to have_button("Previous Level")
  end

  context "when the students's course has a level 0 in it" do
    let(:level_0) { create :level, :zero, course: course }
    let(:target_group_l0) { create :target_group, level: level_0 }
    let!(:level_0_target) do
      create :target,
             :with_shared_assignment,
             target_group: target_group_l0,
             given_role: Assignment::ROLE_TEAM
    end

    scenario "student visits the dashboard" do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_button(level_0.name)

      # Go to the level 0 Tab
      click_button(level_0.name)

      # Ensure only the single level 0 displayed
      expect(page).to have_content(target_group_l0.name)
      expect(page).to have_content(target_group_l0.description)
      expect(page).to have_content(level_0_target.title)
    end
  end

  context "when a student's course has an archived target group in it" do
    let!(:target_group_l4_archived) do
      create :target_group,
             :archived,
             level: level_4,
             description: Faker::Lorem.sentence
    end

    scenario "archived target groups are not displayed" do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_content(target_group_l4_1.name)
      expect(page).not_to have_content(target_group_l4_archived.name)
      expect(page).not_to have_content(target_group_l4_archived.description)
    end
  end

  context "when a user has more than one student profile" do
    context "when the profile is in the same school" do
      let(:course_2) { create :course }
      let(:cohort_2) { create :cohort, course: course_2 }
      let(:c2_level_1) { create :level, :one, course: course_2 }
      let(:c2_target_group) { create :target_group, level: c2_level_1 }
      let!(:c2_target) do
        create :target,
               :with_shared_assignment,
               target_group: c2_target_group,
               given_role: Assignment::ROLE_TEAM
      end
      let!(:c2_student) do
        create :student, user: student.user, cohort: cohort_2
      end

      scenario "student switches to another course" do
        # Sign into the first course.
        sign_in_user c2_student.user, referrer: curriculum_course_path(course)

        expect(page).to have_content(target_group_l4_1.name)

        # Switch to the second course.
        click_button(course.name)
        click_link(course_2.name)

        expect(page).to have_content(c2_target_group.name)
        expect(page).to have_content(c2_target.title)
      end
    end

    context "when the profile is in another school" do
      let(:school_2) { create :school }
      let(:course_2) { create :course, school: school_2 }
      let(:c2_level_1) { create :level, :one, course: course_2 }
      let!(:c2_student) { create :student, user: student.user }

      scenario "courses in other schools are not displayed" do
        # Sign into the first course.
        sign_in_user c2_student.user, referrer: curriculum_course_path(course)

        # There should be no option to switch to course in second school.
        expect(page).not_to have_selector("button.student-course__dropdown-btn")

        # Attempting to visit the course page directly should show a 404.
        visit curriculum_course_path(course_2)
        expect(page).to have_text(
          "The page you were looking for doesn't exist!"
        )
      end
    end
  end

  context "when accessing preview mode of curriculum" do
    let(:school_admin) { create :school_admin }

    scenario "preview contents in the curriculum" do
      sign_in_user school_admin.user, referrer: curriculum_course_path(course)

      expect(page).to have_text("Preview Mode")

      # Course name should be displayed.
      expect(page).to have_content(course.name)

      # An admin should be shown links to edit the level and its targets.
      expect(page).to have_link(
        "Edit Level",
        href: curriculum_school_course_path(id: course.id, level: 1)
      )
      expect(page).to have_selector(
        "a[href='#{content_school_course_target_path(course_id: course.id, id: completed_target_l1.id)}']"
      )

      # The first level should be selected, and all levels should be available.
      click_button "L1: #{level_1.name}"

      [level_2, level_3, level_4, level_5, locked_level_6].each do |l|
        expect(page).to have_button("L#{l.number}: #{l.name}")
      end

      click_button "L6: #{locked_level_6.name}"

      # Being an admin, level 6 should be open, but there should be a notice saying when the level will open for 'regular' students.
      expect(page).to have_content(
        "This level is still locked for students and will be unlocked on #{locked_level_6.unlock_at.strftime("%b %-d")}"
      )
      expect(page).to have_content(target_group_l6.name)
      expect(page).to have_content(target_group_l6.description)
      expect(page).to have_content(level_6_target.title)

      # However, Level 6 should not show the draft target.
      expect(page).not_to have_content(level_6_draft_target.title)

      # Visit the level 5 and ensure that content is in 'preview mode'.
      click_button "L6: #{locked_level_6.name}"
      click_button "L5: #{level_5.name}"

      expect(page).to have_content(target_group_l5.name)
      expect(page).to have_content(target_group_l5.description)
      expect(page).to have_content(l5_reviewed_target.title)

      click_link l5_reviewed_target.title

      expect(page).to have_content(
        "You are currently looking at a preview of this course."
      )
    end
  end

  context "when the student is also a coach" do
    let(:coach) { create :faculty, user: student.user }

    before do
      # Enroll the student as a coach who can review her own submissions.
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: coach,
             student: student
    end

    scenario "coach accesses content in locked levels" do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      click_button "L4: #{level_4.name}"
      click_button "L6: #{locked_level_6.name}"

      # Being a coach, level 6 should be accessible, but there should be a notice saying when the level will open for 'regular' students.
      expect(page).to have_content(
        "This level is still locked for students and will be unlocked on #{locked_level_6.unlock_at.strftime("%b %-d")}"
      )
      expect(page).to have_content(target_group_l6.name)
      expect(page).to have_content(target_group_l6.description)
      expect(page).to have_content(level_6_target.title)

      # However, Level 6 should not show the draft target.
      expect(page).not_to have_content(level_6_draft_target.title)
    end
  end

  context "when a level has no live targets" do
    let!(:level_without_targets) { create :level, number: 7, course: course }

    scenario "level empty message is displayed" do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      click_button "L4: #{level_4.name}"
      click_button "L7: #{level_without_targets.name}"

      expect(page).to have_content("There's no published content on this level")
    end
  end

  context "when a course requires a Discord connection" do
    let(:course) { create :course, discord_account_required: true }

    scenario "student without a connected Discord account is redirected to the user profile edit page" do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_content("Let's link your Discord account first")
    end

    scenario "student with a connected Discord account is shown the curriculum" do
      student.user.update!(discord_user_id: "DISCORD_USER_ID")

      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_content(course.name)
    end

    scenario "inactive student without a connection Discord account should not be redirected" do
      cohort.update(ends_at: 1.day.ago)

      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_content("The course has ended")
    end
  end

  context "when a course has milestones" do
    let!(:milestone_l1) do
      create :target,
             :with_shared_assignment,
             :with_shared_assignment,
             target_group: target_group_l1,
             given_role: Assignment::ROLE_TEAM,
             given_evaluation_criteria: [evaluation_criterion],
             given_milestone_number: 1
    end

    let!(:milestone_l2) do
      create :target,
             :with_shared_assignment,
             :with_shared_assignment,
             target_group: target_group_l2,
             given_role: Assignment::ROLE_TEAM,
             given_evaluation_criteria: [evaluation_criterion],
             given_milestone_number: 2
    end

    let!(:milestone_l3) do
      create :target,
             :with_shared_assignment,
             :with_shared_assignment,
             target_group: target_group_l3,
             given_role: Assignment::ROLE_TEAM,
             given_evaluation_criteria: [evaluation_criterion],
             given_milestone_number: 3
    end
    let!(:milestone_l3_target_version) { create(:target_version, target: milestone_l3) }

    scenario "student checks few milestones" do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      click_button "L4: #{level_4.name}"
      click_button "L1: #{level_1.name}"

      expect(page).to have_content(milestone_l1.title)

      within("a[data-target-id='#{milestone_l1.id}']") do
        expect(page).to have_content("Milestone")
      end

      # No other target in the level should have milestone indication

      within("a[data-target-id='#{completed_target_l1.id}']") do
        expect(page).not_to have_content("Milestone")
      end

      click_button "L1: #{level_1.name}"
      click_button "L3: #{level_3.name}"

      within("a[data-target-id='#{milestone_l3.id}']") do
        expect(page).to have_content("Milestone")
      end

      click_link milestone_l3.title

      expect(page).to have_content(milestone_l3.title)
      expect(page).to have_content("Milestone")
    end
  end

  context "course has a progression limit setting" do
    let(:course) { create :course, progression_limit: 2 }

    # create another pending submission to test the progression limit as there is already one
    let!(:target_1) do
      create :target,
             :with_shared_assignment,
             target_group: target_group_l1,
             given_role: Assignment::ROLE_TEAM,
             given_evaluation_criteria: [evaluation_criterion]
    end
    let!(:target_version_1) { create(:target_version, target: target_1) }

    let!(:submission_pending_t1) do
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [student],
        target: target_1
      )
    end

    # Create another reviewed target to test the progression limit message
    let!(:target_2) do
      create :target,
             :with_shared_assignment,
             target_group: target_group_l1,
             given_role: Assignment::ROLE_TEAM,
             given_evaluation_criteria: [evaluation_criterion]
    end
    let!(:target_version_2) { create(:target_version, target: target_2) }

    scenario "student sees the progression limit lock message when the pending submissions count has reached the limit" do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      within("a[data-target-id='#{target_2.id}']") do
        expect(page).to have_content("Locked")
      end

      click_link target_2.title

      expect(page).to have_content(
        "You have 2 pending submissions and cannot submit more until they are reviewed."
      )

      # Increase the progress limit to check if the lock is gone.
      course.update!(progression_limit: 3)

      visit curriculum_course_path(course)

      within("a[data-target-id='#{target_2.id}']") do
        expect(page).not_to have_content("Locked")
      end

      click_link target_2.title

      expect(page).not_to have_content(
        "You have 2 pending submissions and cannot submit more until they are reviewed."
      )
    end

    context "when a reviewed target has another reviewed target as prerequisite" do
      let!(:target_2) { create :target, target_group: target_group_l1 }
      let!(:assignment_target_2) do
        create :assignment,
               target: target_2,
               role: Assignment::ROLE_TEAM,
               evaluation_criteria: [evaluation_criterion],
               prerequisite_assignments: [target_1.assignments.first]
      end

      before { course.update!(progression_limit: 3) }

      scenario "student attempts to submit the target" do
        sign_in_user student.user, referrer: curriculum_course_path(course)

        # The target should be locked as the prerquisite target is already submitted (need not be reviewed)
        within("a[data-target-id='#{target_2.id}']") do
          expect(page).to_not have_content("Locked")
        end

        click_link target_2.title

        expect(page).not_to have_text(
          "This target has prerequisites that are incomplete."
        )
      end
    end
  end
end
