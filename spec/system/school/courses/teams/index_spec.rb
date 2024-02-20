require "rails_helper"

def teams_path(course)
  "/school/courses/#{course.id}/teams?status=Active"
end

feature "Teams Index", js: true do
  include UserSpecHelper
  include NotificationHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course }
  let!(:ended_cohort) { create :cohort, course: course, ends_at: 1.day.ago }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:team_1) { create :team_with_students, cohort: live_cohort }
  let!(:team_2) { create :team_with_students, cohort: live_cohort }
  let!(:team_ended) { create :team_with_students, cohort: ended_cohort }

  scenario "School admin checkouts active teams" do
    sign_in_user school_admin.user, referrer: teams_path(course)

    expect(page).to have_text(team_1.name)
    expect(page).to have_text(team_2.name)
    expect(page).not_to have_text(team_ended.name)

    within("div[data-team-name='#{team_1.name}']") do
      expect(page).to have_content(team_1.name)
      expect(page).to have_content(team_1.cohort.name)

      team_1.students.each do |student|
        expect(page).to have_content(student.name)
      end
    end

    expect(page).to have_text("Showing all")

    expect(page).to have_link(
      "Create Team",
      href: "/school/courses/#{course.id}/teams/new"
    )
  end

  scenario "School admin checkouts status filter for teams" do
    sign_in_user school_admin.user, referrer: teams_path(course)

    expect(page).to have_text(team_1.name)
    expect(page).not_to have_text(team_ended.name)

    fill_in "Filter Resources", with: "inactive"
    click_button "Pick Status: Inactive"

    within("div[data-team-name='#{team_ended.name}']") do
      expect(page).to have_content(team_ended.name)
      expect(page).to have_content(team_ended.cohort.name)

      team_ended.students.each do |student|
        expect(page).to have_content(student.name)
      end
    end
    expect(page).not_to have_text(team_1.name)

    click_button "Remove selection: Inactive"

    expect(page).to have_text(team_1.name)
    expect(page).to have_text(team_ended.name)
  end

  context "when there are a large number of teams" do
    let!(:teams) { create_list :team_with_students, 30, cohort: live_cohort }

    def safe_random_teams
      @selected_teams_ids ||= []
      team = Team.where.not(id: @selected_teams_ids).order("random()").first
      @selected_teams_ids << team.id
      team
    end

    let(:oldest_created) { safe_random_teams }
    let(:newest_created) { safe_random_teams }
    let(:teams_aaa) { safe_random_teams }
    let(:teams_zzz) { safe_random_teams }

    before do
      teams_aaa.update!(name: "a a aaa")
      teams_zzz.update!(name: "z z zzz")
      oldest_created.update!(created_at: Time.at(0))
      newest_created.update!(created_at: 1.day.from_now)
    end

    scenario "school admin can order teams" do
      sign_in_user school_admin.user, referrer: teams_path(course)

      expect(page).to have_content("Showing 20 of 32 teams")

      # Check ordering by last created
      expect(find(".teams-container:first-child")).to have_text(
        newest_created.name
      )

      click_button("Load More")

      expect(page).to have_selector(".teams-container", count: 32)

      expect(find(".teams-container:last-child")).to have_text(
        oldest_created.name
      )

      # Reverse sorting
      click_button "Order by Last Created"
      click_button "Order by First Created"

      expect(page).to have_selector(".teams-container", count: 20)

      expect(find(".teams-container:first-child")).to have_text(
        oldest_created.name
      )

      click_button("Load More")

      expect(page).to have_selector(".teams-container", count: 32)

      expect(find(".teams-container:last-child")).to have_text(
        newest_created.name
      )

      # Check ordering by name
      click_button "Order by First Created"
      click_button "Order by Name"

      expect(page).to have_selector(".teams-container", count: 20)

      expect(find(".teams-container:first-child")).to have_text(teams_aaa.name)

      click_button("Load More")

      expect(page).to have_selector(".teams-container", count: 32)

      expect(find(".teams-container:last-child")).to have_text(teams_zzz.name)
    end

    scenario "school admin can filter teams" do
      sign_in_user school_admin.user, referrer: teams_path(course)

      expect(page).to have_content("Showing 20 of 32 teams")
      click_button "Order by Last Created"
      click_button "Order by Name"

      expect(page).not_to have_text(teams_zzz.name)

      fill_in "Filter Resources", with: "zzz"
      click_button "Pick Search by Team Name: zzz"

      expect(page).to have_text(teams_zzz.name)
    end
  end
end
