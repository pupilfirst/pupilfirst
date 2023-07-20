require "rails_helper"

feature "Organisation show" do
  include UserSpecHelper

  let(:school) { create :school, :current }

  let!(:organisation_1) { create :organisation, school: school }
  let!(:organisation_2) { create :organisation, school: school }

  let(:school_admin_user) { create :user, school: school }

  let!(:school_admin) do
    create :school_admin, school: school, user: school_admin_user
  end

  let(:org_admin_user) { create :user, school: school }

  let!(:org_admin) do
    create :organisation_admin,
           organisation: organisation_1,
           user: org_admin_user
  end

  let(:regular_user) { create :user, school: school }

  # Two courses.
  let(:course_1) { create :course }
  let(:course_2) { create :course }

  # Three cohorts in course 1, one of which has ended, and one cohort in course 2.
  let(:cohort_1) { create :cohort, course: course_1 }
  let(:cohort_2) { create :cohort, course: course_1 }
  let(:cohort_3) { create :cohort, course: course_1, ends_at: 1.day.ago }
  let(:cohort_4) { create :cohort, course: course_2 }

  # Now the students in org 1.
  let!(:team_c1_o1) { create :team_with_students, cohort: cohort_1 }
  let!(:team_c2_o1) { create :team_with_students, cohort: cohort_2 }
  let!(:team_c3_o1) { create :team_with_students, cohort: cohort_3 }
  let!(:team_c4_o1) { create :team_with_students, cohort: cohort_4 }

  # Org 2 has some active students in cohort 1 as well.
  let!(:team_c1_o2) { create :team_with_students, cohort: cohort_1 }

  # And then a team not in any org.
  let!(:team_c1_no_org) { create :team_with_students, cohort: cohort_1 }

  before do
    # Set up org relationships
    [team_c1_o1, team_c2_o1, team_c3_o1, team_c4_o1].each do |team|
      team
        .students
        .includes(:user)
        .each { |f| f.user.update!(organisation: organisation_1) }
    end

    team_c1_o2
      .students
      .includes(:user)
      .each { |f| f.user.update!(organisation: organisation_2) }
  end

  context "when the user is an organisation admin" do
    scenario "user can see all the active cohorts" do
      sign_in_user(
        org_admin_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_link("My Org", href: "/organisations")
      expect(page).to have_link(
        "#{organisation_1.name}",
        href: "/organisations/#{organisation_1.id}"
      )

      expect(page).to have_text("#{course_1.name}")

      expect(page).to have_content("Active Cohorts")
      # This is visbile only on devices with screen width less than 640px.
      expect(page).to have_text("Active")
      expect(page).to have_content("2")

      expect(page).to have_content("Ended Cohorts")
      # This is visbile only on devices with screen width less than 640px.
      expect(page).to have_text("Ended")
      expect(page).to have_content("1")

      # checking for a link to ended cohorts page.
      expect(page).to have_link(
        "Ended Cohorts",
        href: ended_cohorts_organisation_course_path(organisation_1, course_1)
      )

      # Checking active cohorts.
      within("div[class='border border-gray-200 bg-gray-50 rounded-lg p-5']") do
        expect(page).to have_link(
          cohort_1.name,
          href: organisation_cohort_path(organisation_1, cohort_1)
        )

        expect(page).to have_link(
          cohort_2.name,
          href: organisation_cohort_path(organisation_1, cohort_2)
        )

        expect(page).not_to have_link(
          cohort_3.name,
          href: organisation_cohort_path(organisation_1, cohort_3)
        )

        expect(page).not_to have_link(
          cohort_4.name,
          href: organisation_cohort_path(organisation_2, cohort_4)
        )
      end

      click_link cohort_1.name
      expect(page).to have_current_path(
        organisation_cohort_path(organisation_1, cohort_1)
      )

      # Visit the course 2 page.
      visit active_cohorts_organisation_course_path(organisation_1, course_2)

      expect(page).to have_link("My Org", href: "/organisations")
      expect(page).to have_link(
        "#{organisation_1.name}",
        href: "/organisations/#{organisation_1.id}"
      )

      expect(page).to have_text("#{course_2.name}")

      expect(page).to have_content("Active Cohorts")
      # This is visbile only on devices with screen width less than 640px.
      expect(page).to have_text("Active")
      expect(page).to have_content("1")

      expect(page).to have_content("Ended Cohorts")
      # This is visbile only on devices with screen width less than 640px.
      expect(page).to have_text("Ended")
      expect(page).to have_content("0")

      # Checking active cohorts.
      within("div[class='border border-gray-200 bg-gray-50 rounded-lg p-5']") do
        expect(page).to have_link(
          cohort_4.name,
          href: organisation_cohort_path(organisation_1, cohort_4)
        )
      end
    end

    scenario "user checks navigation links in the breadcrumb" do
      sign_in_user(
        org_admin_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_current_path(
        active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_link(
        "#{organisation_1.name}",
        href: "/organisations/#{organisation_1.id}"
      )
      click_link organisation_1.name
      expect(page).to have_current_path(organisation_path(organisation_1))

      visit active_cohorts_organisation_course_path(organisation_1, course_1)

      expect(page).to have_current_path(
        active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_link("My Org", href: "/organisations")
      click_link "My Org"
      expect(page).to have_current_path("/organisations/#{organisation_1.id}")
    end

    scenario "user can not see the active cohorts page of an orgnisation, where he is not an admin" do
      sign_in_user(
        org_admin_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_2, course_1)
      )

      expect(page).to have_http_status(:not_found)
    end

    scenario "user can visit ended cohorts page from active cohorts page" do
      sign_in_user(
        org_admin_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_current_path(
        active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_link(
        "Ended Cohorts",
        href: ended_cohorts_organisation_course_path(organisation_1, course_1)
      )
      click_link "Ended Cohorts"
      expect(page).to have_current_path(
        ended_cohorts_organisation_course_path(organisation_1, course_1)
      )
    end
  end

  context "when the user is an school admin" do
    scenario "user can see all the Active cohorts" do
      sign_in_user(
        school_admin_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_link("My Org", href: "/organisations")
      expect(page).to have_link(
        "#{organisation_1.name}",
        href: "/organisations/#{organisation_1.id}"
      )

      expect(page).to have_text("#{course_1.name}")

      # This is visbile only on devices with screen width greater than 640px.
      expect(page).to have_content("Active Cohorts")
      # This is visbile only on devices with screen width less than 640px.
      expect(page).to have_text("Active")
      expect(page).to have_content("2")

      # This is visbile only on devices with screen width greater than 640px.
      expect(page).to have_content("Ended Cohorts")
      # This is visbile only on devices with screen width less than 640px.
      expect(page).to have_text("Ended")
      expect(page).to have_content("1")

      # checking for a link to ended cohorts page.
      expect(page).to have_link(
        "Ended Cohorts",
        href: ended_cohorts_organisation_course_path(organisation_1, course_1)
      )

      # Checking active cohorts.
      within("div[class='border border-gray-200 bg-gray-50 rounded-lg p-5']") do
        expect(page).to have_link(
          cohort_1.name,
          href: organisation_cohort_path(organisation_1, cohort_1)
        )

        expect(page).to have_link(
          cohort_2.name,
          href: organisation_cohort_path(organisation_1, cohort_2)
        )

        expect(page).not_to have_link(
          cohort_3.name,
          href: organisation_cohort_path(organisation_1, cohort_3)
        )

        expect(page).not_to have_link(
          cohort_4.name,
          href: organisation_cohort_path(organisation_2, cohort_4)
        )
      end

      click_link cohort_1.name
      expect(page).to have_current_path(
        organisation_cohort_path(organisation_1, cohort_1)
      )

      # Visit the course 2 page.
      visit active_cohorts_organisation_course_path(organisation_1, course_2)

      expect(page).to have_link("My Org", href: "/organisations")
      expect(page).to have_link(
        "#{organisation_1.name}",
        href: "/organisations/#{organisation_1.id}"
      )

      expect(page).to have_text("#{course_2.name}")

      expect(page).to have_content("Active Cohorts")
      # This is visbile only on devices with screen width less than 640px.
      expect(page).to have_text("Active")
      expect(page).to have_content("1")

      expect(page).to have_content("Ended Cohorts")
      # This is visbile only on devices with screen width less than 640px.
      expect(page).to have_text("Ended")
      expect(page).to have_content("0")

      # Checking active cohorts.
      within("div[class='border border-gray-200 bg-gray-50 rounded-lg p-5']") do
        expect(page).to have_link(
          cohort_4.name,
          href: organisation_cohort_path(organisation_1, cohort_4)
        )
      end
    end

    scenario "user checks navigation links in the breadcrumb" do
      sign_in_user(
        school_admin_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_current_path(
        active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_link(
        "#{organisation_1.name}",
        href: "/organisations/#{organisation_1.id}"
      )
      click_link organisation_1.name
      expect(page).to have_current_path(organisation_path(organisation_1))

      visit active_cohorts_organisation_course_path(organisation_1, course_1)

      expect(page).to have_current_path(
        active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_link("My Org", href: "/organisations")
      click_link "My Org"
      expect(page).to have_current_path("/organisations")
    end

    scenario "user can see the active cohorts page of all the organisations" do
      sign_in_user(
        school_admin_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_2, course_1)
      )

      expect(page).not_to have_http_status(:not_found)
    end

    scenario "user can visit ended cohorts page from active cohorts page" do
      sign_in_user(
        school_admin_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_current_path(
        active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_link(
        "Ended Cohorts",
        href: ended_cohorts_organisation_course_path(organisation_1, course_1)
      )
      click_link "Ended Cohorts"
      expect(page).to have_current_path(
        ended_cohorts_organisation_course_path(organisation_1, course_1)
      )
    end
  end

  context "when the user is a non-admin" do
    scenario "user can not see the ended cohorts page" do
      sign_in_user(
        regular_user,
        referrer:
          active_cohorts_organisation_course_path(organisation_1, course_1)
      )

      expect(page).to have_http_status(:not_found)
    end
  end
end
