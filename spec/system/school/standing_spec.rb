require "rails_helper"

feature "School Standing", js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper

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

  context "When school has standing enabled and standings are created" do
    before do
      # Enable standings in the school configuration
      school.update!(configuration: { enable_standing: true })
    end
    # Create additional standings
    let!(:standing_1) { create :standing, default: true }
    let!(:standing_2) { create :standing }
    let!(:standing_3) { create :standing }

    let!(:user_standing_1) do
      create :user_standing, user: school_admin.user, standing: standing_2
    end

    scenario "school admin tries to delete a standing" do
      sign_in_user school_admin.user, referrer: standing_school_path

      expect(page).to have_content("Standings")

      # Standing 2 will be archived because it has a user_standing
      alert_text =
        accept_confirm do
          find("button[id='delete_standing_#{standing_2.id}']").click
        end

      expect(alert_text).to have_text(
        "Are you sure you want to archive this standing? It has 1 log associated with it."
      )

      expect(page).not_to have_text(standing_2.name)

      # Standing 3 will be deleted because it has no user_standings
      alert_text =
        accept_confirm do
          find("button[id='delete_standing_#{standing_3.id}']").click
        end

      expect(alert_text).to have_text(
        "Are you sure you want to delete this standing? It has no logs associated with it."
      )

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

    scenario "School admin tries to add code of conduct for the school" do
      sign_in_user school_admin.user, referrer: standing_school_path

      expect(page).to have_text("Enabled")

      click_link "Add CoC"

      expect(page).to have_text("Code of Conduct")

      code_of_conduct = Faker::Lorem.sentence
      add_markdown(code_of_conduct)

      click_button "Save Code of Conduct"

      expect(page).to have_text("Code of Conduct saved successfully")

      click_link "Edit CoC"

      expect(page).to have_text("Code of Conduct")

      within("textarea[name='code_of_conduct_editor']") do
        expect(page).to have_text(code_of_conduct)
      end

      code_of_conduct = Faker::Lorem.sentence
      replace_markdown(code_of_conduct)

      click_button "Save Code of Conduct"

      expect(page).to have_text("Code of Conduct saved successfully")

      click_link "View CoC"

      expect(page).to have_current_path(
        agreement_path(agreement_type: "code-of-conduct")
      )
    end
  end

  scenario "student cannot access the school standing page" do
    sign_in_user create(:student, school: school).user,
                 referrer: standing_school_path

    expect(page).to have_current_path("/school/standing")

    expect(page).to have_text("The page you were looking for doesn't exist")
  end

  scenario "coach cannot access the school standing page" do
    sign_in_user create(:faculty, school: school).user,
                 referrer: standing_school_path

    expect(page).to have_current_path("/school/standing")

    expect(page).to have_text("The page you were looking for doesn't exist")
  end
end
