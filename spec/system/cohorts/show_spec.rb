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
  let(:cohort_inactive) { create :cohort, course: course }
  let!(:team_1) { create :team_with_students, cohort: cohort }
  let!(:team_2) { create :team_with_students, cohort: cohort }
  let!(:team_3) { create :team_with_students, cohort: cohort_inactive }

  before do
    # Set up org relationships
    [team_1, team_2, team_3].each do |team|
      team
        .students
        .includes(:user)
        .each { |f| f.user.update!(organisation: organisation) }
    end

    # Mark one team of students as having completed the course.
    team_2.students.each { |f| f.update!(completed_at: 1.day.ago) }
  end

  context "when the user is an organisation admin" do
    scenario "user can access org overview of active cohort", js: true do
      sign_in_user org_admin_user,
                   referrer: organisation_cohort_path(organisation, cohort)

      expect(page).to have_text("Total Students\n4")
      expect(page).to have_text("Students Completed\n2")
      expect(page).to have_text("Level-wise student distribution")

      expect(page).to have_link(
        "Students",
        href: students_organisation_cohort_path(organisation, cohort)
      )
    end

    scenario "user can access org overview of inactive cohort" do
      sign_in_user org_admin_user,
                   referrer:
                     organisation_cohort_path(organisation, cohort_inactive)

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
    scenario "user can access org overview of active cohort" do
      sign_in_user school_admin_user,
                   referrer: organisation_cohort_path(organisation, cohort)

      expect(page).to have_text("Total Students\n4")
    end

    scenario "user can access org overview of inactive cohort" do
      sign_in_user school_admin_user,
                   referrer:
                     organisation_cohort_path(organisation, cohort_inactive)

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
