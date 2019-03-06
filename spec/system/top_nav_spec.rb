require 'rails_helper'

feature 'Top navigation bar' do
  let(:founder) { create :founder }

  let!(:custom_link_1) { create :school_link, :header, school: founder.school }
  let!(:custom_link_2) { create :school_link, :header, school: founder.school }
  let!(:custom_link_3) { create :school_link, :header, school: founder.school }
  let!(:custom_link_4) { create :school_link, :header, school: founder.school }

  it 'displays custom links on the navbar', js: true do
    visit new_user_session_path

    # Three should be visible directly.
    expect(page).to have_link(custom_link_4.title, href: custom_link_4.url)
    expect(page).to have_link(custom_link_3.title, href: custom_link_3.url)
    expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)

    # The last should be visible within a dropdown button.
    expect(page).not_to have_link(custom_link_1.title, href: custom_link_1.url)

    within('#nav-links__navbar') do
      click_link 'More'
    end

    # The last link should now be visible.
    expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)
  end

  context 'when the user is a school admin, coach, and student' do
    it 'displays all main links on the navbar and puts custom links in the dropdown'
  end
end
