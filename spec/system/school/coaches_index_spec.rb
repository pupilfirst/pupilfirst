require "rails_helper"

feature "Coaches Index", js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with a single student target, ...
  let!(:school) { create :school, :current }
  let!(:school_1) { create :school }
  let!(:coach_1) { create :faculty, school: school }
  let!(:coach_2) { create :faculty, school: school }
  let!(:coach_3) { create :faculty, school: school_1 }

  let(:new_coach_name) { Faker::Name.name }
  let(:new_coach_email) { Faker::Internet.email(name: new_coach_name) }
  let(:new_coach_title) { Faker::Lorem.words(number: 2).join(" ") }
  let(:new_coach_affiliation) { Faker::Lorem.words(number: 2).join(" ") }

  let(:updated_coach_name) { Faker::Name.name }
  let(:updated_coach_title) { Faker::Lorem.words(number: 2).join(" ") }

  let!(:school_admin) { create :school_admin, school: school }

  scenario "school admin adds a new coach and edits details" do
    sign_in_user school_admin.user, referrer: school_coaches_path

    # list all coaches
    expect(page).to have_text("Add New Coach")
    expect(page).to have_text(coach_1.name)
    expect(page).to have_text(coach_2.name)
    expect(page).to_not have_text(coach_3.name)

    # Add a coach with minimum required fields.
    click_button "Add New Coach"

    fill_in "Name", with: new_coach_name
    fill_in "Email", with: new_coach_email
    fill_in "Title", with: new_coach_title
    fill_in "Affiliation", with: new_coach_affiliation

    click_button "Add Coach"

    expect(page).to have_text(new_coach_name)

    coach = Faculty.last
    user = coach.user

    expect(user.name).to eq(new_coach_name)
    expect(user.title).to eq(new_coach_title)
    expect(user.email).to eq(new_coach_email)
    expect(user.affiliation).to eq(new_coach_affiliation)
    expect(coach.connect_link).to eq(nil)
    expect(coach.public).to eq(false)

    # Edit the coach to add remaining fields.
    find("p", text: new_coach_name).click

    fill_in "Connect Link", with: "https://www.connect.com/xyz"
    expect(page).to have_text(
      "Since the coach profile isn't public, this won't be shown anywhere"
    )
    within('div[aria-label="public-profile-selector"]') { click_button "Yes" } # Should the coach profile be public?
    expect(page).not_to have_text(
      "Since the coach profile isn't public, this won't be shown anywhere"
    )
    attach_file "faculty[image]",
                File.absolute_path(
                  Rails.root.join("spec/support/uploads/faculty/human.png")
                ),
                visible: false
    fill_in "Name", with: updated_coach_name
    expect(page).not_to have_field("Email")
    fill_in "Title", with: updated_coach_title
    fill_in "Affiliation", with: ""
    click_button "Update Coach"

    # expect(page).to have_text("Coach updated successfully")
    expect(page).to have_text(updated_coach_name) # wait for page to reload

    expect(coach.reload.connect_link).to eq("https://www.connect.com/xyz")
    expect(coach.public).to eq(true)
    expect(user.avatar.attached?).to eq(true)
    expect(user.avatar.filename).to eq("human.png")
    expect(user.reload.name).to eq(updated_coach_name)
    expect(user.title).to eq(updated_coach_title)
    expect(user.affiliation).to eq(nil)
  end

  scenario "user who is not logged in gets redirected to sign in page" do
    visit school_coaches_path
    expect(page).to have_text("Please sign in to continue.")
  end

  scenario "school admin archives a coach" do
    sign_in_user school_admin.user, referrer: school_coaches_path

    expect(page).to have_text(coach_1.name)
    expect(page).to have_text(coach_2.name)

    find("p", text: coach_1.name).click
    click_button "Exited"
    click_button "Update Coach"

    expect(page).to_not have_text(coach_1.name)
    expect(page).to have_text(coach_2.name)
    expect(coach_1.reload.exited).to eq(true)
  end

  scenario "school admin visits exited tab" do
    coach_1.update!(exited: true)

    sign_in_user school_admin.user,
                 referrer: school_coaches_path(status: "exited")
    expect(page).to have_text(coach_1.name)
    expect(page).to_not have_text(coach_2.name)
    expect(page).to_not have_text(coach_3.name)
  end

  context "with multiple pages of coaches" do
    before do
      Faculty.destroy_all # remove previous coaches, interfering with this test
      15.times { create :faculty }
    end
    scenario "school admin paginates through coaches on active tab" do
      sign_in_user school_admin.user,
                   referrer: school_coaches_path(status: "active")

      expect(page).to have_link(
        "2",
        href: "/school/coaches?page=2&status=active"
      )
      expect(page).to have_selector(".course-faculty__list-item ", count: 10)
      click_link "2"
      expect(page).to have_selector(".course-faculty__list-item", count: 5)
    end

    scenario "school admin paginates through coaches on exited tab" do
      Faculty.all.limit(5).each { |faculty| faculty.update!(exited: true) }

      sign_in_user school_admin.user,
                   referrer: school_coaches_path(status: "exited")

      expect(page).to_not have_link(
        "2",
        href: "/school/coaches?page=2&status=exited"
      )
      expect(page).to have_selector(".course-faculty__list-item", count: 5)
    end
  end
end
