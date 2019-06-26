require 'rails_helper'

feature 'Top navigation bar' do
  include UserSpecHelper

  let(:student) { create :founder }
  let(:coach) { create :faculty, school: student.school, user: student.user }

  # Create a target so that dashoard can render.
  # TODO: Remove this once we have a generic home page. The user can be sent there instead for this test.

  it 'displays custom links on the navbar', js: true do
    visit new_user_session_path

    expect(page).not_to have_link('Admin', href: '/school')
    expect(page).not_to have_link('Home', href: "/home")
  end

  context 'when the user is a school admin and student' do
    before do
      # Make the user a school admin.
      create :school_admin, user: student.user, school: student.school
    end

    it 'displays all main links on the navbar', js: true do
      sign_in_user student.user, referer: leaderboard_course_path(student.course)

      expect(page).to have_link('Admin', href: '/school')
      expect(page).to have_link('Home', href: "/home")
    end
  end

  context 'when the user is a student' do
    it 'displays home link on the navbar', js: true do
      sign_in_user student.user, referer: leaderboard_course_path(student.course)

      expect(page).not_to have_link('Admin', href: '/school')
      expect(page).to have_link('Home', href: "/home")
    end
  end
end
