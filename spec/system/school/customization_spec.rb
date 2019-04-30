require 'rails_helper'

feature 'School Customization' do
  include UserSpecHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }

  before do
    # Create a domain for school
    create :domain, :primary, school: school
  end

  def image_path(filename)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'files', filename))
  end

  scenario 'school admin sets custom images', js: true do
    sign_in_user school_admin.user, referer: customize_school_path

    find('div[title="Edit logo (on light backgrounds)"]').click

    # Unhappy path.
    attach_file 'icon', image_path('high_resolution.png'), visible: false

    click_button 'Update Images'

    expect(page).to have_content('Icon must be a JPEG, PNG, or GIF, less than 4096 pixels wide or high')

    # Happy path.
    attach_file 'logo_on_light_bg', image_path('logo_sv_on_light_bg.png'), visible: false
    attach_file 'logo_on_dark_bg', image_path('logo_sv_on_dark_bg.png'), visible: false
    attach_file 'icon', image_path('icon_sv.png'), visible: false

    click_button 'Update Images'

    expect(page).to have_content('Images have been updated successfully')

    expect(school.reload.logo_on_light_bg.filename).to eq('logo_sv_on_light_bg.png')
    expect(school.logo_on_dark_bg.filename).to eq('logo_sv_on_dark_bg.png')
    expect(school.icon.filename).to eq('icon_sv.png')
  end

  scenario 'school admin sets custom links', js: true do
    sign_in_user school_admin.user, referer: customize_school_path

    expect(page).to have_content("You can customize links on the header.")

    # Add four links and check that they're all displayed.
    find('div[title="Edit header links"]').click

    (1..4).each do |link_number|
      fill_in "Title", with: "Test Link #{link_number}"
      fill_in "Full URL", with: "http://example.com/#{link_number}"
      click_button "Add a New Link"
      expect(page).to have_selector("button[title='Delete http://example.com/#{link_number}']")
      find('.ui-pnotify-container').click
    end

    header_links = school.school_links.where(kind: SchoolLink::KIND_HEADER)
    expect(header_links.count).to eq(4)
    expect(header_links.first.title).to eq('Test Link 1')
    expect(header_links.first.url).to eq('http://example.com/1')

    find('button[title="Close Editor"]').click

    expect(page).not_to have_content("More")

    # Add one more link to ensure that last two links are in the more dropdown.
    find('div[title="Edit header links"]').click

    fill_in "Title", with: "Test Link 5"
    fill_in "Full URL", with: "http://example.com/5"
    click_button "Add a New Link"
    expect(page).to have_selector("button[title='Delete http://example.com/5']")
    find('.ui-pnotify-container').click

    find('button[title="Close Editor"]').click

    expect(page).not_to have_content("Test Link 4")
    expect(page).not_to have_content("Test Link 5")

    find('div[title="Show more links"]').click

    expect(page).to have_content("Test Link 4")
    expect(page).to have_content("Test Link 5")

    # Let's try removing header links and adding sitemap and social links.
    expect(page).to have_content("You can customize links in the footer.")
    expect(page).to have_content("Add social media links?")

    find('div[title="Edit header links"]').click

    (1..5).each do |link_number|
      find("button[title='Delete http://example.com/#{link_number}']").click
      expect(page).not_to have_selector("button[title='Delete http://example.com/#{link_number}']")
    end

    expect(header_links.count).to eq(0)

    find("div[title='Show footer links']").click

    fill_in "Title", with: "Test Footer Link"
    fill_in "Full URL", with: "http://example.com/footer"
    click_button "Add a New Link"
    find('.ui-pnotify-container').click

    expect(page).to have_selector("button[title='Delete http://example.com/footer']")

    find("div[title='Show social media links']").click

    fill_in "Full URL", with: "http://twitter.com"
    click_button "Add a New Link"
    find('.ui-pnotify-container').click

    expect(page).to have_selector("button[title='Delete http://twitter.com']")

    find('button[title="Close Editor"]').click

    expect(page).not_to have_content("You can customize links in the footer.")
    expect(page).not_to have_content("Add social media links?")

    footer_links = school.school_links.where(kind: SchoolLink::KIND_FOOTER)
    social_links = school.school_links.where(kind: SchoolLink::KIND_SOCIAL)

    expect(footer_links.count).to eq(1)
    expect(social_links.count).to eq(1)

    expect(footer_links.first.title).to eq('Test Footer Link')
    expect(footer_links.first.url).to eq('http://example.com/footer')

    expect(social_links.first.title).to eq(nil)
    expect(social_links.first.url).to eq('http://twitter.com')
  end
end
