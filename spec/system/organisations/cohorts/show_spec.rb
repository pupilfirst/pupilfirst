require "rails_helper"

feature "Organisation show" do
  include UserSpecHelper

  let(:school) { create :school, :current }

  let!(:organisation) { create :organisation, school: school }
  let(:school_admin_user) { create :user, school: school }

  let!(:school_admin) do
    create :school_admin, school: school, user: school_admin_user
  end

  let(:org_admin_user) { create :user, school: school }

  let!(:org_admin) do
    create :organisation_admin, organisation: organisation, user: org_admin_user
  end

  let(:regular_user) { create :user, school: school }

  let(:course) { create :course }
  let(:cohort) { create :cohort, course: course }
  let(:cohort_ended) { create :cohort, course: course }
  let!(:team_1) { create :team_with_students, cohort: cohort }
  let!(:team_2) { create :team_with_students, cohort: cohort }
  let!(:team_3) { create :team_with_students, cohort: cohort_ended }

  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:course_coach) { create :faculty, school: school }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }

  let!(:target_group_l1) { create :target_group, level: level_1 }
  let!(:target_group_l2) { create :target_group, level: level_2 }

  let!(:target_l1) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l1,
           given_role: Assignment::ROLE_STUDENT,
           given_evaluation_criteria: [evaluation_criterion],
           given_milestone_number: 1
  end
  let!(:target_l2) do
    create :target,
           :with_shared_assignment,
           target_group: target_group_l2,
           given_role: Assignment::ROLE_STUDENT,
           given_evaluation_criteria: [evaluation_criterion],
           given_milestone_number: 2
  end

  before do
    # Set up org relationships
    [team_1, team_2, team_3].each do |team|
      team
        .students
        .includes(:user)
        .each { |f| f.user.update!(organisation: organisation) }
    end

    # Mark one team of students as having completed the course.
    team_2.students.each do |f|
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [f],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 2.days.ago,
        passed_at: 3.days.ago
      )

      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [f],
        target: target_l2,
        evaluator_id: course_coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago
      )

      f.update!(completed_at: 1.day.ago)
    end

    # Add an archived submission from another team
    team_1.students.each do |s|
      create(
        :timeline_event,
        :with_owners,
        latest: true,
        owners: [s],
        target: target_l1,
        evaluator_id: course_coach.id,
        evaluated_at: 1.day.ago,
        passed_at: 1.day.ago,
        archived_at: 1.hour.ago
      )
    end
  end

  context "when the user is an organisation admin" do
    scenario "user can access org overview of active cohort", js: true do
      sign_in_user org_admin_user,
                   referrer: organisation_cohort_path(organisation, cohort)

      expect(page).to have_text("Total Students\n4")
      expect(page).to have_text("Students Completed\n2")
      expect(page).to have_text("Student Distribution by Milestone Completion")

      expect(page).to have_text(
        "M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"
      )

      expect(page).to have_text(
        "M#{target_l2.assignments.first.milestone_number}: #{target_l2.title}"
      )

      expect(page).to have_text("2/4", count: 2)

      expect(page).to have_link(
        "Students",
        href: students_organisation_cohort_path(organisation, cohort)
      )
    end

    scenario "user can visit tab by clicking on the milestone pill", js: true do
      sign_in_user org_admin_user,
                   referrer: organisation_cohort_path(organisation, cohort)

      find(
        "a[href='#{students_organisation_cohort_path(organisation, cohort, milestone_completed: "#{target_l1.id};M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}")}']"
      ).click

      expect(page).to have_text(team_2.students.first.name)
      expect(page).not_to have_text(team_1.students.first.name)

      fill_in "Filter", with: "M"
      click_button "Milestone completed: M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"

      # Team 1's student name should not be listed in the page anymore.
      expect(page).not_to have_text(team_1.students.first.name)
    end

    scenario "user can access org overview of ended cohort" do
      sign_in_user org_admin_user,
                   referrer:
                     organisation_cohort_path(organisation, cohort_ended)

      expect(page).to have_text("Total Students\n2")
    end

    scenario "user checks navigation links in the breadcrumb" do
      sign_in_user(
        org_admin_user,
        referrer: organisation_cohort_path(organisation, cohort)
      )

      expect(page).to have_current_path(
        organisation_cohort_path(organisation, cohort)
      )

      expect(page).to have_link(
        "#{course.name}",
        href: active_cohorts_organisation_course_path(organisation, course)
      )
      click_link course.name
      expect(page).to have_current_path(
        active_cohorts_organisation_course_path(organisation, course)
      )
    end
  end

  context "when the user is a school admin" do
    scenario "user can access org overview of a active cohort" do
      sign_in_user school_admin_user,
                   referrer: organisation_cohort_path(organisation, cohort)

      expect(page).to have_text("Total Students\n4")

      expect(page).to have_text("Student Distribution by Milestone Completion")

      expect(page).to have_text(
        "M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}"
      )

      expect(page).to have_text(
        "M#{target_l2.assignments.first.milestone_number}: #{target_l2.title}"
      )

      expect(page).to have_link(
        "Students",
        href: students_organisation_cohort_path(organisation, cohort)
      )
    end

    scenario "user can visit tab by clicking on the milestone pill" do
      sign_in_user school_admin_user,
                   referrer: organisation_cohort_path(organisation, cohort)

      find(
        "a[href='#{students_organisation_cohort_path(organisation, cohort, milestone_completed: "#{target_l1.id};M#{target_l1.assignments.first.milestone_number}: #{target_l1.title}")}']"
      ).click

      expect(page).to have_text(team_2.students.first.name)
      expect(page).not_to have_text(team_1.students.first.name)
    end

    scenario "user can access org overview of ended cohort" do
      sign_in_user school_admin_user,
                   referrer:
                     organisation_cohort_path(organisation, cohort_ended)

      expect(page).to have_text("Total Students\n2")
    end

    scenario "user checks navigation links in the breadcrumb" do
      sign_in_user(
        school_admin_user,
        referrer: organisation_cohort_path(organisation, cohort)
      )

      expect(page).to have_current_path(
        organisation_cohort_path(organisation, cohort)
      )

      expect(page).to have_link(
        "#{course.name}",
        href: active_cohorts_organisation_course_path(organisation, course)
      )
      click_link course.name
      expect(page).to have_current_path(
        active_cohorts_organisation_course_path(organisation, course)
      )
    end
  end

  context "when the user is a regular user" do
    scenario "user cannot access org overview of a cohort" do
      sign_in_user regular_user,
                   referrer: organisation_cohort_path(organisation, cohort)

      expect(page).to have_http_status(:not_found)
    end
  end
end
