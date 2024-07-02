require "rails_helper"

feature "Users Index", js: true do
  include UserSpecHelper
  include NotificationHelper

  let(:school) { create :school, :current }
  let(:school_2) { create :school }

  let(:school_admin) { create :school_admin, school: school }
  let!(:school_2_user) { create :user, school: school_2 }

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  scenario "school admins visit users index page" do
    sign_in_user school_admin.user, referrer: school_users_path

    expect(page).to have_text(school_admin.user.name)
    expect(page).to_not have_text(school_2_user.name)
    expect(page).to have_text("Displaying 1 User")
  end

  context "school has many users and admins uses filters" do
    before { 23.times { create :user, school: school } }

    let!(:author) { create :course_author, user: school_admin.user }
    let!(:coach) { create :faculty, school: school }

    let!(:student_1) { create :student, user: school.users.first }
    let!(:student_2) { create :student, user: school.users.second }

    scenario "admin paginate users" do
      sign_in_user school_admin.user, referrer: school_users_path

      expect(page).to have_text("Displaying Users 1 - 24 of 25 in total")

      click_link "Next ›"

      expect(page).to have_text(school.users.order(name: :asc).last.name)
    end

    scenario "admin filters by name" do
      sign_in_user school_admin.user, referrer: school_users_path

      last_user = User.last

      fill_in "Filter", with: last_user.name
      click_button "Name: #{last_user.name}"

      expect(page).to have_text(last_user.name)
    end

    scenario "admins filters by email" do
      sign_in_user school_admin.user, referrer: school_users_path

      last_user = User.last

      fill_in "Filter", with: last_user.email
      click_button "Email: #{last_user.email}"

      expect(page).to have_text(last_user.name)
      expect(page).to have_text("Displaying 1 User")
    end

    scenario "admin filters all students" do
      sign_in_user school_admin.user, referrer: school_users_path

      fill_in "Filter", with: "Students"
      click_button "Show: Students"

      expect(page).to have_text(student_1.user.name)
      expect(page).to have_text(student_2.user.name)

      expect(page).to have_text("Displaying all 2 Users")
    end

    scenario "admins filters by coaches" do
      sign_in_user school_admin.user, referrer: school_users_path

      fill_in "Filter", with: "Coaches"
      click_button "Show: Coaches"

      expect(page).to have_text(coach.user.name)
      expect(page).to have_text("Displaying 1 User")
    end

    scenario "admin filters by authors" do
      sign_in_user school_admin.user, referrer: school_users_path

      fill_in "Filter", with: "Authors"
      click_button "Show: Authors"

      expect(page).to have_text(author.user.name)
      expect(page).to have_text("Displaying 1 User")
    end
  end
end
