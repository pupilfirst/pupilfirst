require 'rails_helper'

feature 'Top navigation bar' do
  include UserSpecHelper

  let(:student) { create :founder }
  let(:coach) { create :faculty, school: student.school, user: student.user }

  # Create a target so that dashoard can render.
  # TODO: Remove this once we have a generic home page. The user can be sent there instead for this test.
  let(:target_group) { create :target_group, level: student.level, milestone: true }
  let!(:target) { create :target, target_group: target_group }

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
      within('#nav-links__navbar') do
        click_link 'More'
      end

      expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)
    end
  end

  context 'when the user is a school admin, coach, and student' do
    before do
      # Make the user a school admin.
      create :school_admin, user: student.user, school: student.school

      # Enroll the coach as reviewer for course that the same user (student) is in.
      create :faculty_course_enrollment, faculty: coach, course: student.course
    end

    it 'displays all main links on the navbar and puts custom links in the dropdown', js: true do
      sign_in_user student.user, referer: student_dashboard_path

      expect(page).to have_link('Admin', href: '/school')
      expect(page).to have_link('Review Submissions', href: "/courses/#{student.course.id}/coach_dashboard")
      expect(page).to have_link('Student Dashboard', href: '/student/dashboard')

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

  context 'when the user can review submissions from multiple courses' do
    let(:another_course) { create :course, school: student.school }
    let(:another_level) { create :level, course: another_course }
    let(:another_student) { create :founder, level: another_level }

    before do
      # Enroll the coach as reviewer for course that 'student' is in.
      create :faculty_course_enrollment, faculty: coach, course: student.course

      # Enroll the coach as reviewer for team in another course in the same school.
      create :faculty_startup_enrollment, faculty: coach, startup: another_student.startup
    end

    it 'displays review submission links in a dropdown', js: true do
      sign_in_user student.user, referer: student_dashboard_path

      # One of the custom options should be visible.
      expect(page).to have_link(custom_link_4.title, href: custom_link_4.url)

      # The other three custom options should not be visible.
      expect(page).not_to have_link(custom_link_3.title, href: custom_link_3.url)
      expect(page).not_to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).not_to have_link(custom_link_1.title, href: custom_link_1.url)

      # However, they should be accessible in the 'More' dropdown.
      within('#nav-links__navbar') do
        click_link 'More'
      end

      expect(page).to have_link(custom_link_3.title, href: custom_link_3.url)
      expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)

      # Links to the review dashboard should not be visible.
      expect(page).not_to have_link(student.course.name, href: "/courses/#{student.course.id}/coach_dashboard")
      expect(page).not_to have_link(another_student.course.name, href: "/courses/#{another_student.course.id}/coach_dashboard")

      # They should be in a 'Review Submissions' dropdown.
      within('#nav-links__navbar') do
        click_link 'Review Submissions'
      end

      expect(page).to have_link(student.course.name, href: "/courses/#{student.course.id}/coach_dashboard")
      expect(page).to have_link(another_student.course.name, href: "/courses/#{another_student.course.id}/coach_dashboard")
    end
  end

  context 'when the user is a student in multiple courses of the same school' do
    let(:another_course) { create :course, school: student.school }
    let(:another_level) { create :level, course: another_course }
    let!(:another_student) { create :founder, level: another_level, user: student.user }

    it 'displays the student dashboard link as a dropdown', js: true do
      sign_in_user student.user, referer: student_dashboard_path

      # The 'Student Dashboard' option should be an anchor link.
      expect(page).to have_link('Student Dashboard', href: '#')

      # The option to switch to different student profiles should not be immediately visible.
      expect(page).not_to have_link("#{another_student.course.name} Course", href: "/founders/#{another_student.slug}/select")
      expect(page).not_to have_link("#{student.course.name} Course", href: "/founders/#{student.slug}/select")

      # But, visible within the dropdown.
      within('#nav-links__navbar') do
        click_link 'Student Dashboard'
      end

      expect(page).to have_link("#{another_student.course.name} Course", href: "/founders/#{another_student.slug}/select")
      expect(page).to have_link("#{student.course.name} Course", href: "/founders/#{student.slug}/select")
    end
  end

  context 'when the user is a student in a course that has leaderboard entries in the past week' do
    let(:lts) { LeaderboardTimeService.new }

    before do
      create :leaderboard_entry, founder: student, period_from: lts.week_start, period_to: lts.week_end
    end

    it 'displays a link to the leaderboard' do
      sign_in_user student.user, referer: student_dashboard_path

      expect(page).to have_link('Leaderboard', href: "/courses/#{student.course.id}/leaderboard")
    end
  end
end
