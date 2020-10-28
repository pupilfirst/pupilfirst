require 'rails_helper'

feature "Student's view of Course Curriculum", js: true do
  include NotificationHelper
  include UserSpecHelper

  # The basics.
  let(:course) { create :course }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:team) { create :startup, level: level_4 }
  let(:dashboard_toured) { true }
  let!(:student) { create :founder, startup: team }
  let(:faculty) { create :faculty }

  # Levels.
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:level_3) { create :level, :three, course: course }
  let!(:level_4) { create :level, :four, course: course }
  let!(:level_5) { create :level, :five, course: course }
  let!(:locked_level_6) { create :level, :six, course: course, unlock_at: 1.month.from_now }

  # Target group we're interested in. Create milestone
  let!(:target_group_l1) { create :target_group, level: level_1, milestone: true }
  let!(:target_group_l2) { create :target_group, level: level_2, milestone: true }
  let!(:target_group_l3) { create :target_group, level: level_3, milestone: true }
  let!(:target_group_l4_1) { create :target_group, level: level_4, milestone: true }
  let!(:target_group_l4_2) { create :target_group, level: level_4 }
  let!(:target_group_l5) { create :target_group, level: level_5, milestone: true }
  let!(:target_group_l6) { create :target_group, level: locked_level_6, milestone: true }

  # Individual targets of different types.
  let!(:completed_target_l1) { create :target, target_group: target_group_l1, role: Target::ROLE_TEAM }
  let!(:completed_target_l2) { create :target, target_group: target_group_l2, role: Target::ROLE_TEAM }
  let!(:completed_target_l3) { create :target, target_group: target_group_l3, role: Target::ROLE_TEAM }
  let!(:completed_target_l4) { create :target, target_group: target_group_l4_1, role: Target::ROLE_TEAM, evaluation_criteria: [evaluation_criterion] }
  let!(:pending_target_g1) { create :target, target_group: target_group_l4_1, role: Target::ROLE_TEAM }
  let!(:pending_target_g2) { create :target, target_group: target_group_l4_2, role: Target::ROLE_TEAM }
  let!(:submitted_target) { create :target, target_group: target_group_l4_1, role: Target::ROLE_TEAM, evaluation_criteria: [evaluation_criterion] }
  let!(:failed_target) { create :target, target_group: target_group_l4_1, role: Target::ROLE_TEAM, evaluation_criteria: [evaluation_criterion] }
  let!(:target_with_prerequisites) { create :target, target_group: target_group_l4_1, prerequisite_targets: [pending_target_g1], role: Target::ROLE_TEAM }
  let!(:l5_reviewed_target) { create :target, target_group: target_group_l5, role: Target::ROLE_TEAM, evaluation_criteria: [evaluation_criterion] }
  let!(:l5_non_reviewed_target) { create :target, :with_markdown, target_group: target_group_l5, role: Target::ROLE_TEAM }
  let!(:l5_non_reviewed_target_with_prerequisite) { create :target, :with_markdown, target_group: target_group_l5, role: Target::ROLE_TEAM, prerequisite_targets: [l5_non_reviewed_target] }
  let!(:level_6_target) { create :target, target_group: target_group_l6, role: Target::ROLE_TEAM }
  let!(:level_6_draft_target) { create :target, :draft, target_group: target_group_l6, role: Target::ROLE_TEAM }

  # Submissions
  let!(:submission_completed_target_l1) { create(:timeline_event, :with_owners, latest: true, owners: team.founders, target: completed_target_l1, passed_at: 1.day.ago) }
  let!(:submission_completed_target_l2) { create(:timeline_event, :with_owners, latest: true, owners: team.founders, target: completed_target_l2, passed_at: 1.day.ago) }
  let!(:submission_completed_target_l3) { create(:timeline_event, :with_owners, latest: true, owners: team.founders, target: completed_target_l3, passed_at: 1.day.ago) }
  let!(:submission_completed_target_l4) { create(:timeline_event, :with_owners, latest: true, owners: team.founders, target: completed_target_l4, passed_at: 1.day.ago, evaluator: faculty, evaluated_at: 1.day.ago) }
  let!(:submission_submitted_target) { create(:timeline_event, :with_owners, latest: true, owners: team.founders, target: submitted_target) }
  let!(:submission_failed_target) { create(:timeline_event, :with_owners, latest: true, owners: team.founders, target: failed_target, evaluator: faculty, evaluated_at: Time.zone.now) }

  before do
    # Grading for graded targets
    create(:timeline_event_grade, timeline_event: submission_completed_target_l4, evaluation_criterion: evaluation_criterion, grade: 2)
    create(:timeline_event_grade, timeline_event: submission_failed_target, evaluation_criterion: evaluation_criterion, grade: 1)
  end

  around do |example|
    Time.use_zone(student.user.time_zone) { example.run }
  end

  scenario "student who has dropped out attempts to view a course's curriculum" do
    student.startup.update!(dropped_out_at: 1.day.ago)
    sign_in_user student.user, referrer: curriculum_course_path(course)
    expect(page).to have_content("The page you were looking for doesn't exist!")
  end

  context 'when the course the student belongs has ended' do
    let(:course) { create :course, ends_at: 1.day.ago }

    scenario 'student visits the course curriculum page' do
      sign_in_user student.user, referrer: curriculum_course_path(course)
      expect(page).to have_text('The course has ended and submissions are disabled for all targets!')
    end
  end

  context "when a student's access to a course has ended" do
    let!(:team) { create :startup, level: level_4, access_ends_at: 1.day.ago }

    scenario 'student visits the course curriculum page' do
      sign_in_user student.user, referrer: curriculum_course_path(course)
      expect(page).to have_text('Your access to this course has ended.')
    end
  end

  scenario 'student visits the course curriculum page' do
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
    within("a[aria-label='Select Target #{completed_target_l4.id}']") do
      expect(page).to have_content('Completed')
    end

    within("a[aria-label='Select Target #{submitted_target.id}']") do
      expect(page).to have_content('Pending Review')
    end

    within("a[aria-label='Select Target #{failed_target.id}']") do
      expect(page).to have_content('Rejected')
    end

    within("a[aria-label='Select Target #{target_with_prerequisites.id}']") do
      expect(page).to have_content('Locked')
    end

    expect(page).to have_content(target_group_l4_1.name)
    expect(page).to have_content(target_group_l4_1.description)

    # There should only be two target groups...
    expect(page).to have_selector('.curriculum__target-group', count: 2)

    # ...and only one of thoese should be a milestone target group.
    expect(page).to have_selector('.curriculum__target-group', text: 'MILESTONE TARGETS', count: 1)

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

    within("a[aria-label='Select Target #{completed_target_l2.id}']") do
      expect(page).to have_content('Completed')
    end
  end

  scenario 'student browses a level she has not reached' do
    sign_in_user student.user, referrer: curriculum_course_path(course)

    # Switch to Level 5.
    click_button "L4: #{level_4.name}"
    click_button "L5: #{level_5.name}"

    expect(page).to have_text(target_group_l5.name)
    expect(page).to have_text(target_group_l5.description)

    # There should be two locked targets in L5 right now.
    expect(page).to have_selector('.curriculum__target-status--locked', count: 2)

    # Non-reviewed targets that have prerequisites must be locked.
    click_link l5_non_reviewed_target_with_prerequisite.title

    expect(page).to have_text('This target has pre-requisites that are incomplete.')
    expect(page).to have_link(l5_non_reviewed_target.title)

    click_button 'Close'

    # Non-reviewed targets that do not have prerequisites should be unlocked for completion.
    click_link l5_non_reviewed_target.title
    click_button 'Mark As Complete'

    expect(page).to have_text('Target has been marked as complete')

    dismiss_notification
    click_button 'Close'

    # Completing the prerequisite should unlock the previously locked non-reviewed target.
    expect(page).to have_selector('.curriculum__target-status--locked', count: 1)

    click_link l5_non_reviewed_target_with_prerequisite.title

    expect(page).not_to have_text('This target has pre-requisites that are incomplete.')
    expect(page).to have_button 'Mark As Complete'

    click_button 'Close'

    # Reviewed targets, even those without prerequisites, must be locked.
    click_link l5_reviewed_target.title

    expect(page).to have_content('You must level up to complete this target')

    click_button 'Close'
  end

  scenario 'student opens a locked level' do
    sign_in_user student.user, referrer: curriculum_course_path(course)

    # Switch to the locked Level 6.
    click_button "L4: #{level_4.name}"
    click_button "L6: #{locked_level_6.name}"

    # Ensure level 6 is displayed as locked. - the content should not be visible.
    expect(page).to have_text('The level is currently locked!')
    expect(page).to have_text('You can access the content on')
    expect(page).not_to have_text(target_group_l6.name)
    expect(page).not_to have_text(target_group_l6.description)
    expect(page).not_to have_text(level_6_target.title)
  end

  scenario 'student navigates between levels using the quick navigation links' do
    sign_in_user student.user, referrer: curriculum_course_path(course)

    expect(page).to have_button("L4: #{level_4.name}")

    click_button 'Next Level'

    expect(page).to have_button("L5: #{level_5.name}")

    click_button 'Next Level'

    expect(page).to have_button("L6: #{locked_level_6.name}")
    expect(page).not_to have_button('Next Level')

    click_button 'Previous Level'
    click_button "L5: #{level_5.name}"
    click_button "L2: #{level_2.name}"
    click_button 'Previous Level'

    expect(page).to have_button("L1: #{level_1.name}")
    expect(page).not_to have_button('Previous Level')
  end

  context "when the students's course has a level 0 in it" do
    let(:level_0) { create :level, :zero, course: course }
    let(:target_group_l0) { create :target_group, level: level_0 }
    let!(:level_0_target) { create :target, target_group: target_group_l0, role: Target::ROLE_TEAM }

    scenario 'student visits the dashboard' do
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
    let!(:target_group_l4_archived) { create :target_group, :archived, level: level_4, milestone: true, description: Faker::Lorem.sentence }

    scenario 'archived target groups are not displayed' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_content(target_group_l4_1.name)
      expect(page).not_to have_content(target_group_l4_archived.name)
      expect(page).not_to have_content(target_group_l4_archived.description)
    end
  end

  context 'when a user has more than one student profile' do
    context 'when the profile is in the same school' do
      let(:course_2) { create :course }
      let(:c2_level_1) { create :level, :one, course: course_2 }
      let(:c2_target_group) { create :target_group, level: c2_level_1 }
      let!(:c2_target) { create :target, target_group: c2_target_group, role: Target::ROLE_TEAM }
      let(:c2_team) { create :startup, level: c2_level_1 }
      let!(:c2_student) { create :founder, startup: c2_team, dashboard_toured: dashboard_toured, user: student.user }

      scenario 'student switches to another course' do
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

    context 'when the profile is in another school' do
      let(:school_2) { create :school }
      let(:course_2) { create :course, school: school_2 }
      let(:c2_level_1) { create :level, :one, course: course_2 }
      let(:c2_team) { create :startup, level: c2_level_1 }
      let!(:c2_student) { create :founder, startup: c2_team, dashboard_toured: dashboard_toured, user: student.user }

      scenario 'courses in other schools are not displayed' do
        # Sign into the first course.
        sign_in_user c2_student.user, referrer: curriculum_course_path(course)

        # There should be no option to switch to course in second school.
        expect(page).not_to have_selector('button.student-course__dropdown-btn')

        # Attempting to visit the course page directly should show a 404.
        visit curriculum_course_path(course_2)
        expect(page).to have_text("The page you were looking for doesn't exist!")
      end
    end
  end

  context 'when accessing preview mode of curriculum' do
    let(:school_admin) { create :school_admin }

    scenario 'preview contents in the curriculum' do
      sign_in_user school_admin.user, referrer: curriculum_course_path(course)

      expect(page).to have_text('Preview Mode')

      # Course name should be displayed.
      expect(page).to have_content(course.name)

      # The first level should be selected, and all levels should be available.
      click_button "L1: #{level_1.name}"

      [level_2, level_3, level_4, level_5, locked_level_6].each do |l|
        expect(page).to have_button("L#{l.number}: #{l.name}")
      end

      click_button "L6: #{locked_level_6.name}"

      # Being an admin, level 6 should be open, but there should be a notice saying when the level will open for 'regular' students.
      expect(page).to have_content("This level is still locked for students, and will be unlocked on #{locked_level_6.unlock_at.strftime('%b %-d')}")
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

      expect(page).to have_content('You are currently looking at a preview of this course.')
    end
  end

  context 'when the student is also a coach' do
    let(:coach) { create :faculty, user: student.user }

    before do
      # Enroll the student as a coach who can review her own submissions.
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach, startup: team
    end

    scenario 'coach accesses content in locked levels' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      click_button "L4: #{level_4.name}"
      click_button "L6: #{locked_level_6.name}"

      # Being a coach, level 6 should be accessible, but there should be a notice saying when the level will open for 'regular' students.
      expect(page).to have_content("This level is still locked for students, and will be unlocked on #{locked_level_6.unlock_at.strftime('%b %-d')}")
      expect(page).to have_content(target_group_l6.name)
      expect(page).to have_content(target_group_l6.description)
      expect(page).to have_content(level_6_target.title)

      # However, Level 6 should not show the draft target.
      expect(page).not_to have_content(level_6_draft_target.title)
    end
  end

  context 'when a level has no live targets' do
    let!(:level_without_targets) { create :level, number: 7, course: course }

    scenario 'level empty message is displayed' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      click_button "L4: #{level_4.name}"
      click_button "L7: #{level_without_targets.name}"

      expect(page).to have_content("There's no published content on this level")
    end
  end
end
