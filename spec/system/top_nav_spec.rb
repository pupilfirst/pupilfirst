require 'rails_helper'

feature 'Top navigation bar' do
  include UserSpecHelper

  let(:student) { create :founder }
  let(:coach) { create :faculty, school: student.school, user: student.user }

  let!(:custom_link_1) { create :school_link, :header, school: student.school }
  let!(:custom_link_2) { create :school_link, :header, school: student.school }
  let!(:custom_link_3) { create :school_link, :header, school: student.school }
  let!(:custom_link_4) { create :school_link, :header, school: student.school }

  it 'displays custom links on the navbar', js: true do
    visit new_user_session_path

    # All four links should be visible.
    expect(page).to have_link(custom_link_4.title, href: custom_link_4.url)
    expect(page).to have_link(custom_link_3.title, href: custom_link_3.url)
    expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)
    expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)

    # The 'More' option should not be visible.
    expect(page).not_to have_link('More')

    expect(page).not_to have_link('Admin', href: '/school')
    expect(page).not_to have_link('Dashboard', href: "/dashboard")
  end

  context 'when the user is a school admin and student' do
    before do
      # Make the user a school admin.
      create :school_admin, user: student.user, school: student.school
    end

    it 'displays all main links on the navbar and puts custom links in the dropdown', js: true do
      sign_in_user student.user, referrer: leaderboard_course_path(student.course)

      expect(page).to have_link('Admin', href: '/school')
      expect(page).to have_link('Dashboard', href: "/dashboard")
      expect(page).to have_link(custom_link_4.title, href: custom_link_4.url)

      # None of the custom links should be visible by default.
      expect(page).not_to have_link(custom_link_3.title, href: custom_link_3.url)
      expect(page).not_to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).not_to have_link(custom_link_1.title, href: custom_link_1.url)

      within('div[title="Show more links"]') do
        find('span', text: 'More').click
      end

      # All the custom links should now be displayed.
      expect(page).to have_link(custom_link_3.title, href: custom_link_3.url)
      expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)
    end
  end

  context 'when the user is a student' do
    it 'displays dashboard link on the navbar', js: true do
      sign_in_user student.user, referrer: leaderboard_course_path(student.course)

      expect(page).not_to have_link('Admin', href: '/school')
      expect(page).to have_link('Dashboard', href: "/dashboard")
    end
  end

  context 'when there are more than four custom links' do
    let!(:custom_link_5) { create :school_link, :header, school: student.school }

    it 'displays additional links in a "More" dropdown', js: true do
      visit new_user_session_path

      # Three links should be visible.
      expect(page).to have_link(custom_link_5.title, href: custom_link_5.url)
      expect(page).to have_link(custom_link_4.title, href: custom_link_4.url)
      expect(page).to have_link(custom_link_3.title, href: custom_link_3.url)

      # Other two should not be visible.
      expect(page).not_to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).not_to have_link(custom_link_1.title, href: custom_link_1.url)

      # They should be in the 'More' dropdown.
      within('div[title="Show more links"]') do
        find('span', text: 'More').click
      end

      expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)
    end
  end
end
