require "rails_helper"

def cohorts_new_path(course)
  "/school/courses/#{course.id}/cohorts/new"
end

feature "Cohorts New", js: true do
  include UserSpecHelper
  include NotificationHelper
  include DateHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course }
  let!(:level) { create :level, :one, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:student) { create :student, cohort: live_cohort }
  let(:name) { Faker::Lorem.words(number: 2).join(" ") }
  let(:description) { Faker::Lorem.sentences.join(" ") }

  scenario "School admin creates a cohort" do
    sign_in_user school_admin.user, referrer: cohorts_new_path(course)

    expect(page).to have_text("Add new cohort")

    fill_in "Cohort name", with: name
    fill_in "Cohort description", with: description

    click_button "Add new cohort"
    dismiss_notification

    within("div[data-cohort-name='#{name}']") do
      expect(page).to have_content(description)
    end

    cohort = Cohort.last

    expect(cohort.name).to eq(name)
    expect(cohort.description).to eq(description)
    expect(cohort.ends_at).to eq(nil)
    expect(Cohort.count).to eq(2)
  end

  scenario "School admin creates a cohort with an end date" do
    ends_at = Date.tomorrow.iso8601
    sign_in_user school_admin.user, referrer: cohorts_new_path(course)

    expect(page).to have_text("Add new cohort")

    fill_in "Cohort name", with: name
    fill_in "Cohort description", with: description
    fill_in "Cohort end date", with: ends_at

    click_button "Add new cohort"
    dismiss_notification

    within("div[data-cohort-name='#{name}']") do
      expect(page).to have_content(description)
    end

    cohort = Cohort.last

    expect(cohort.name).to eq(name)
    expect(cohort.description).to eq(description)
    expect(cohort.ends_at).to eq(date_to_zoned_time(ends_at))
  end

  scenario "logged in user who is not a school admin tries to access create cohort page" do
    sign_in_user student.user, referrer: cohorts_new_path(course)
    expect(page).to have_text("The page you were looking for doesn't exist!")
  end

  scenario "school admin tries to access an invalid link" do
    sign_in_user school_admin.user,
                 referrer: "/school/courses/888888/cohorts/new"
    expect(page).to have_text(
      "Sorry, The page you are looking for doesn't exist or has been moved."
    )
  end

  context "when adding a cohort with a name that already exists" do
    let(:existing_cohort) { create(:cohort, course: course) }
    let(:different_course) { create(:course, school: school) }

    scenario "adding a cohort with the same name in the same course errors out" do
      sign_in_user school_admin.user, referrer: cohorts_new_path(course)

      expect(page).to have_text("Add new cohort")

      fill_in "Cohort name", with: existing_cohort.name
      fill_in "Cohort description", with: description

      click_button "Add new cohort"

      expect(page).to have_text("Name has already been taken")
      expect(Cohort.count).to eq(2)
    end

    scenario "adding a cohort with the same name in a different course is allowed" do
      sign_in_user school_admin.user,
                   referrer: cohorts_new_path(different_course)

      expect(page).to have_text("Add new cohort")

      fill_in "Cohort name", with: existing_cohort.name
      fill_in "Cohort description", with: description

      click_button "Add new cohort"

      expect(page).to have_text("Cohort created successfully")
      expect(different_course.cohorts.count).to eq(1)
      expect(Cohort.count).to eq(3)
    end
  end
end
