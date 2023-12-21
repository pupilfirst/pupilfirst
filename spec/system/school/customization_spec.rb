require "rails_helper"

feature "School Customization", js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with a single student target, ...
  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }

  def image_path(filename)
    File.absolute_path(
      Rails.root.join("spec", "support", "uploads", "files", filename)
    )
  end

  scenario "school admin sets custom images" do
    sign_in_user school_admin.user, referrer: customize_school_path

    find('button[title="Edit logo (on light backgrounds)"]').click

    # Unhappy path.
    attach_file "icon_on_light_bg",
                image_path("high_resolution.png"),
                visible: false

    click_button "Update Images"

    expect(page).to have_content(
      "Icon on light bg must be a JPEG, PNG, or GIF, less than 4096 pixels wide or high"
    )

    # Happy path.
    attach_file "logo_on_light_bg",
                image_path("logo_lipsum_on_light_bg.png"),
                visible: false
    attach_file "logo_on_dark_bg",
                image_path("logo_lipsum_on_dark_bg.png"),
                visible: false
    attach_file "icon_on_dark_bg", image_path("icon_white.png"), visible: false
    attach_file "icon_on_light_bg",
                image_path("icon_pupilfirst.png"),
                visible: false
    attach_file "cover_image", image_path("cover_image.jpg"), visible: false

    click_button "Update Images"

    expect(page).to have_content("Images have been updated successfully")

    expect(school.reload.logo_on_light_bg.filename).to eq(
      "logo_lipsum_on_light_bg.png"
    )
    expect(school.icon_on_light_bg.filename).to eq("icon_pupilfirst.png")
    expect(school.cover_image.filename).to eq("cover_image.jpg")
  end

  scenario "school admin sets custom links" do
    sign_in_user school_admin.user, referrer: customize_school_path

    expect(page).to have_content("You can customize links on the header.")

    # Add four links and check that they're all displayed.
    find('button[title="Edit header links"]').click

    (1..4).each do |link_number|
      fill_in "Title", with: "Test Link #{link_number}"
      fill_in "Full URL", with: "http://example.com/#{link_number}"
      click_button "Add a New Link"
      expect(page).to have_selector(
        "button[aria-label='Delete http://example.com/#{link_number}']"
      )
      dismiss_notification
    end

    header_links = school.school_links.where(kind: SchoolLink::KIND_HEADER)
    expect(header_links.count).to eq(4)
    expect(header_links.first.title).to eq("Test Link 1")
    expect(header_links.first.url).to eq("http://example.com/1")

    find('button[title="Close Editor"]').click

    expect(page).not_to have_content("More")

    # Add one more link to ensure that last two links are in the more dropdown.
    find('button[title="Edit header links"]').click

    fill_in "Title", with: "Test Link 5"
    fill_in "Full URL", with: "http://example.com/5"
    click_button "Add a New Link"
    expect(page).to have_selector(
      "button[aria-label='Delete http://example.com/5']"
    )
    dismiss_notification

    find('button[title="Close Editor"]').click

    expect(page).not_to have_content("Test Link 4")
    expect(page).not_to have_content("Test Link 5")

    find('button[title="Show more links"]').click

    expect(page).to have_content("Test Link 4")
    expect(page).to have_content("Test Link 5")

    # Let's try removing header links and adding sitemap and social links.
    expect(page).to have_content("You can customize links in the footer.")
    expect(page).to have_content("Add social media links?")

    find('button[title="Edit header links"]').click

    (1..5).each do |link_number|
      find(
        "button[aria-label='Delete http://example.com/#{link_number}']"
      ).click
      expect(page).not_to have_selector(
        "button[aria-label='Delete http://example.com/#{link_number}']"
      )
    end

    expect(header_links.count).to eq(0)

    find("button[title='View and edit footer links']").click

    fill_in "Title", with: "Test Footer Link"
    fill_in "Full URL", with: "http://example.com/footer"
    click_button "Add a New Link"
    dismiss_notification
    sleep 0.1
    expect(page).to have_selector(
      "button[aria-label='Delete http://example.com/footer']"
    )

    find("button[title='View and edit social media links']").click

    fill_in "Full URL", with: "http://twitter.com"
    click_button "Add a New Link"
    dismiss_notification

    expect(page).to have_selector(
      "button[aria-label='Delete http://twitter.com']"
    )

    find('button[title="Close Editor"]').click

    expect(page).not_to have_content("You can customize links in the footer.")
    expect(page).not_to have_content("Add social media links?")

    footer_links = school.school_links.where(kind: SchoolLink::KIND_FOOTER)
    social_links = school.school_links.where(kind: SchoolLink::KIND_SOCIAL)

    expect(footer_links.count).to eq(1)
    expect(social_links.count).to eq(1)

    expect(footer_links.first.title).to eq("Test Footer Link")
    expect(footer_links.first.url).to eq("http://example.com/footer")

    expect(social_links.first.title).to eq(nil)
    expect(social_links.first.url).to eq("http://twitter.com")
  end

  scenario "school admin customizes strings" do
    sign_in_user school_admin.user, referrer: customize_school_path

    expect(page).to have_content("Add an address?")
    expect(page).to have_content("Add a contact email?")

    # Edit basic contact details.
    find('button[title="Edit contact details"]').click

    address = Faker::Address.full_address
    email = Faker::Internet.email

    fill_in "Contact Address", with: address
    fill_in "Email Address", with: email

    click_button "Update Contact Details"

    expect(page).to have_content("Contact details have been updated")
    dismiss_notification

    find('button[title="Close Editor"]').click

    expect(page).not_to have_content("Add an address?")
    expect(page).not_to have_content("Add a contact email?")

    expect(SchoolString::Address.for(school)).to eq(address)
    expect(SchoolString::EmailAddress.for(school)).to eq(email)

    # Edit privacy policy.
    find('button[title="Edit privacy policy"]').click

    privacy_policy = Faker::Lorem.paragraphs(number: 2).join("\n\n")

    fill_in("Body of Agreement", with: privacy_policy)
    click_button "Update Privacy Policy"
    expect(page).to have_content("Privacy Policy has been updated")
    dismiss_notification

    find('button[title="Close Editor"]').click

    # Edit terms & conditions.
    find('button[title="Edit Terms & Conditions"]').click

    terms_and_conditions = Faker::Lorem.paragraphs(number: 2).join("\n\n")

    fill_in("Body of Agreement", with: terms_and_conditions)
    click_button "Update Terms & Conditions"
    expect(page).to have_content("Terms & Conditions has been updated")
    dismiss_notification

    find('button[title="Close Editor"]').click

    # Edit code of conduct.
    find('button[title="Edit Code of Conduct"]').click

    code_of_conduct = Faker::Lorem.paragraphs(number: 2).join("\n\n")

    fill_in("Body of Agreement", with: code_of_conduct)
    click_button "Update Code of Conduct"
    expect(page).to have_content("Code of Conduct has been updated")

    expect(SchoolString::PrivacyPolicy.for(school)).to eq(privacy_policy)
    expect(SchoolString::TermsAndConditions.for(school)).to eq(
      terms_and_conditions
    )
    expect(SchoolString::CodeOfConduct.for(school)).to eq(code_of_conduct)
  end

  scenario "school admin customizes school name and about" do
    sign_in_user school_admin.user, referrer: customize_school_path

    expect(page).to have_content(school.name)
    expect(page).to have_content("Add more details about the school")

    # Edit basic contact details.
    find('button[aria-label="Edit school details"]').click

    about = Faker::Lorem.paragraphs(number: 2).join(" ")
    name = Faker::Name.name

    fill_in "School Name", with: name
    fill_in "About", with: about

    click_button "Update"

    expect(page).to have_content("Details updated successfully!")
    dismiss_notification

    expect(school.reload.name).to eq(name)
    expect(school.about).to eq(about)
  end

  scenario "user who is not logged in gets redirected to sign in page" do
    visit customize_school_path
    expect(page).to have_text("Please sign in to continue.")
  end

  context "there are already existing links in the school" do
    let!(:school_header_link_1) do
      create :school_link,
             kind: SchoolLink::KIND_HEADER,
             school: school,
             sort_index: 0
    end
    let!(:school_header_link_2) do
      create :school_link,
             kind: SchoolLink::KIND_HEADER,
             school: school,
             sort_index: 1
    end
    let!(:school_header_link_3) do
      create :school_link,
             kind: SchoolLink::KIND_HEADER,
             school: school,
             sort_index: 2
    end

    # Add another school with its associated links.

    let!(:school_2) { create :school }

    let!(:school_2_header_link_1) do
      create :school_link,
             kind: SchoolLink::KIND_HEADER,
             school: school_2,
             sort_index: 1
    end
    let!(:school_2_header_link_2) do
      create :school_link,
             kind: SchoolLink::KIND_HEADER,
             school: school_2,
             sort_index: 2
    end

    let!(:school_footer_link_1) do
      create :school_link,
             kind: SchoolLink::KIND_FOOTER,
             school: school,
             sort_index: 0
    end

    scenario "admin updates and changes order of links" do
      sign_in_user school_admin.user, referrer: customize_school_path
      find('button[title="Edit header links"]').click

      within("div[data-school-link-id='#{school_header_link_1.id}']") do
        expect(page).to have_selector("button[title='Move Up']")
        expect(page).to have_selector("button[title='Move Down']")

        # move first link down
        find("button[title='Move Down']").click
        sleep 0.1
        expect(school_header_link_1.reload.sort_index).to eq(1)
        expect(school_header_link_2.reload.sort_index).to eq(0)
        expect(school_header_link_3.reload.sort_index).to eq(2)

        find("button[title='Move Up']").click
        sleep 0.1
        expect(school_header_link_1.reload.sort_index).to eq(0)
        expect(school_header_link_2.reload.sort_index).to eq(1)
        expect(school_header_link_3.reload.sort_index).to eq(2)
      end

      # check that the other school's links are not affected

      expect(school_2_header_link_1.reload.sort_index).to eq(1)
      expect(school_2_header_link_2.reload.sort_index).to eq(2)

      within("div[data-school-link-id='#{school_header_link_1.id}']") do
        # update link
        find("button[title='Edit']").click
        fill_in "link-title-#{school_header_link_1.id}",
                with: "Test Link 1 updated"
        fill_in "link-url-#{school_header_link_1.id}",
                with: "http://example.com/1/updated"

        find("button[title='Update']").click
      end

      expect(page).to have_content("Link updated successfully!")
      dismiss_notification

      expect(school_header_link_1.reload.title).to eq("Test Link 1 updated")
      expect(school_header_link_1.url).to eq("http://example.com/1/updated")
    end

    scenario "school admin tries to update a link with empty title" do
      sign_in_user school_admin.user, referrer: customize_school_path
      find('button[title="Edit header links"]').click

      click_button "Footer Sitemap"

      expect(page).to have_text("Current Sitemap Links")

      within("div[data-school-link-id='#{school_footer_link_1.id}']") do
        find("button[title='Edit']").click
        fill_in "link-title-#{school_footer_link_1.id}", with: ""
      end

      expect(page).to have_content(
        "Please enter a non empty title with no more than 24 characters"
      )
      expect(page).to have_button("Update", disabled: true)
    end

    scenario "school admin tries to update a link title with more than 24 characters" do
      sign_in_user school_admin.user, referrer: customize_school_path
      find('button[title="Edit header links"]').click

      click_button "Footer Sitemap"

      expect(page).to have_text("Current Sitemap Links")

      within("div[data-school-link-id='#{school_footer_link_1.id}']") do
        find("button[title='Edit']").click
        fill_in "link-title-#{school_footer_link_1.id}", with: "A" * 25
      end

      # The title field has a max length of 24 characters.
      expect(
        page.find("#link-title-#{school_footer_link_1.id}").value.length
      ).to eq(24)

      expect(page).to have_button("Update", disabled: false)
    end
  end

  scenario "school admin tries to create a link with empty title" do
    sign_in_user school_admin.user, referrer: customize_school_path
    find('button[title="Edit header links"]').click

    click_button "Footer Sitemap"

    fill_in "Title", with: ""
    fill_in "Full URL", with: "http://example.com/empty_title"
    expect(page).to have_content(
      "Please enter a non empty title with no more than 24 characters"
    )

    expect(page).to have_button("Add a New Link", disabled: true)
  end

  scenario "school admin tries to add a link title with more than 24 characters" do
    sign_in_user school_admin.user, referrer: customize_school_path
    find('button[title="Edit header links"]').click

    click_button "Footer Sitemap"

    fill_in "Title", with: "A" * 25
    fill_in "Full URL", with: "http://example.com/empty_title"

    # The title field has a max length of 24 characters.
    expect(page.find("#link-title").value.length).to eq(24)

    expect(page).to have_button("Add a New Link", disabled: false)
  end
end
