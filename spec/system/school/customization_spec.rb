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

    expect(page).to have_content('Header')
    expect(page).to have_content('Footer')
    expect(page).to have_content('Icon')

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
end
