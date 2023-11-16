require "rails_helper"

feature "School Standing", js: true do
  include UserSpecHelper
  include NotificationHelper

  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }

  scenario "school admin vists the standing page and enables the standing" do
    sign_in_user school_admin.user, referrer: standing_school_path

    expect(page).to have_content("Standings")

    expect(page).not_to have_text("Enabled")

    click_button "Yes"

    expect(page).to have_text("Enabled")

    expect(page).to have_link("Add CoC")

    expect(page).to have_text("Neutral")

    expect(page).to have_text("Default")

    expect(page).not_to have_selector(
      "button[id='delete_standing_1']",
      visible: :all
    )
  end

  context "Add more standing" do
    before do
      # Enable standings in the school configuration
      school.update!(configuration: { enable_standing: true })
    end
    # Create additional standings
    let!(:standing_1) { create :standing, default: true }
    let!(:standing_2) { create :standing }
    let!(:standing_3) { create :standing }

    scenario "school admin tries to delete a standing" do
      sign_in_user school_admin.user, referrer: standing_school_path

      expect(page).to have_content("Standings")

      accept_confirm do
        find("button[id='delete_standing_#{standing_2.id}']").click
      end

      expect(page).not_to have_text(standing_2.name)

      expect(page).to have_text(standing_1.name)
    end

    scenario "school admin tries to edit a standing" do
      sign_in_user school_admin.user, referrer: standing_school_path

      expect(page).to have_content("Standings")

      find("a[id='edit_standing_#{standing_2.id}']").click

      expect(page).to have_text("Edit #{standing_2.name}")

      expect(page).to have_field(
        "standing_description",
        with: standing_2.description
      )

      expect(page).to have_field("color_picker", with: standing_2.color)

      fill_in "standing_description", with: "New description"

      color_value = "#ff0000"

      # Find the color picker and set its value
      find("#color_picker").set(color_value)

      # Verify that the value has been set correctly
      expect(find("#color_picker").value).to eq(color_value)

      click_button "Save Standing"

      expect(page).to have_text("Standing updated successfully")

      visit "/school/standings/#{standing_2.id}/edit"

      expect(page).to have_field(
        "standing_description",
        with: "New description"
      )

      expect(page).to have_field("color_picker", with: color_value)
    end

    scenario "school admin tries to add a standing" do
      sign_in_user school_admin.user, referrer: standing_school_path

      expect(page).to have_content("Standings")

      click_button "Add another standing"

      expect(page).to have_text("Add new standing")

      new_standing_name = Faker::Lorem.word
      new_standing_description = Faker::Lorem.sentence
      new_standing_color = Faker::Color.hex_color

      fill_in "standing_name", with: new_standing_name

      fill_in "standing_description", with: new_standing_description

      find("#color_picker").set(new_standing_color)

      expect(find("#color_picker").value).to eq(new_standing_color)

      click_button "Save Standing"

      expect(page).to have_text("Standing created successfully")

      expect(page).to have_text(new_standing_name)
    end
  end
end
