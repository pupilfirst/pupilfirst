require "rails_helper"

def cohorts_details_path(cohort)
  "/school/cohorts/#{cohort.id}/details"
end

feature "Cohorts Details", js: true do
  include UserSpecHelper
  include NotificationHelper
  include DateHelper

  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course, ends_at: 1.day.from_now }
  let!(:ended_cohort) { create :cohort, course: course, ends_at: 1.day.ago }
  let!(:level) { create :level, :one, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:student) { create :student, cohort: live_cohort }

  let(:name) { Faker::Lorem.words(number: 2).join(" ") }
  let(:description) { Faker::Lorem.sentences.join(" ") }
  let(:ends_at) { 15.days.from_now.to_date.iso8601 }

  scenario "School admin updates name, description and ends at for a cohort" do
    sign_in_user school_admin.user, referrer: cohorts_details_path(live_cohort)

    expect(page.find_field("Cohort name").value).to eq(live_cohort.name)
    expect(page.find_field("Cohort description").value).to eq(
      live_cohort.description
    )

    fill_in "Cohort name", with: name, fill_options: { clear: :backspace }
    fill_in "Cohort description",
            with: description,
            fill_options: {
              clear: :backspace
            }
    fill_in "Cohort end date",
            with: ends_at,
            fill_options: {
              clear: :backspace
            }

    click_button "Update cohort"
    dismiss_notification

    expect(live_cohort.reload.name).to eq(name)
    expect(live_cohort.description).to eq(description)
    expect(live_cohort.ends_at).to eq(date_to_zoned_time(ends_at))
  end

  scenario "School admin updates name, description and ends at for a cohort" do
    sign_in_user school_admin.user, referrer: cohorts_details_path(ended_cohort)

    expect(page.find_field("Cohort name").value).to eq(ended_cohort.name)
    expect(page.find_field("Cohort description").value).to eq(
      ended_cohort.description
    )
    expect(ended_cohort.ends_at).not_to eq(nil)

    fill_in "Cohort end date", with: "", fill_options: { clear: :backspace }

    click_button "Update cohort"
    dismiss_notification

    expect(ended_cohort.reload.ends_at).to eq(nil)
  end

  scenario "logged in user who is not a school admin tries to access cohort details page" do
    sign_in_user student.user, referrer: cohorts_details_path(course)
    expect(page).to have_text("The page you were looking for doesn't exist!")
  end

  scenario "school admin tries to access an invalid link" do
    sign_in_user school_admin.user, referrer: "/school/cohorts/888888/details"
    expect(page).to have_text(
      "Sorry, The page you are looking for doesn't exist or has been moved."
    )
  end

  context "when updating a cohort with a name that already exists" do
    let(:existing_cohort) { create(:cohort, course: course) }
    let(:another_course) { create :course, school: school }
    let!(:cohort_in_another_course) { create(:cohort, course: another_course) }

    scenario "updating a cohort in the same course errors out" do
      sign_in_user school_admin.user,
                   referrer: cohorts_details_path(existing_cohort)

      fill_in "Cohort name", with: live_cohort.name
      click_button "Update cohort"

      expect(page).to have_text("Name has already been taken")
    end

    scenario "updating a cohort in a different course is allowed" do
      sign_in_user school_admin.user,
                   referrer: cohorts_details_path(existing_cohort)

      fill_in "Cohort name", with: cohort_in_another_course.name
      click_button "Update cohort"

      expect(page).to have_text("Cohort updated successfully")
    end

    scenario "updating the same name does not error out" do
      sign_in_user school_admin.user,
                   referrer: cohorts_details_path(existing_cohort)

      fill_in "Cohort name", with: existing_cohort.name
      click_button "Update cohort"

      expect(page).to have_text("Cohort updated successfully")
    end
  end
end
