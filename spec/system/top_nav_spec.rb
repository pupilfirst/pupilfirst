require 'rails_helper'

feature 'Top navigation bar' do
  include UserSpecHelper

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
    let(:coach) { create :faculty, school: founder.school, user: founder.user }

    before do
      # Create a target so that dashoard can render.
      # TODO: Remove this once we have a generic home page. The user can be sent there instead for this test.
      tg = create :target_group, level: founder.level, milestone: true
      create :target, target_group: tg

      # Make the user a school admin.
      create :school_admin, user: founder.user, school: founder.school

      # Enroll the coach as reviewer for course that the same user (student) is in.
      create :faculty_course_enrollment, faculty: coach, course: founder.course
    end

    it 'displays all main links on the navbar and puts custom links in the dropdown', js: true do
      sign_in_user founder.user, referer: student_dashboard_path

      expect(page).to have_link('Admin', href: '/school')
      expect(page).to have_link('Review', href: "/courses/#{founder.course.id}/coach_dashboard")
      expect(page).to have_link('Dashboard', href: '/student/dashboard')

      # None of the custom links should be visible by default.
      expect(page).not_to have_link(custom_link_4.title, href: custom_link_4.url)
      expect(page).not_to have_link(custom_link_3.title, href: custom_link_3.url)
      expect(page).not_to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).not_to have_link(custom_link_1.title, href: custom_link_1.url)

      within('#nav-links__navbar') do
        click_link 'More'
      end

      # All the custom links should now be displayed.
      expect(page).to have_link(custom_link_4.title, href: custom_link_4.url)
      expect(page).to have_link(custom_link_3.title, href: custom_link_3.url)
      expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)
    end
  end
end
