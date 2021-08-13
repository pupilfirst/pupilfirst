require 'rails_helper'
feature 'App navigation', js: true do
  include UserSpecHelper

  let(:student) { create :founder }
  let(:coach) { create :faculty, school: student.school, user: student.user }

  let!(:custom_link_1) { create :school_link, :header, school: student.school }
  let!(:custom_link_2) { create :school_link, :header, school: student.school }
  let!(:custom_link_3) { create :school_link, :header, school: student.school }
  let!(:custom_link_4) { create :school_link, :header, school: student.school }

  let(:coached_course) { create :course }
  let(:another_coached_course) { create :course }

  context 'when the user is a school admin and coach' do
    before do
      # Make the user a school admin.
      create :school_admin, user: student.user, school: student.school

      # Enroll one coach as a "course" coach.
      create :faculty_course_enrollment, faculty: coach, course: coached_course
    end

    it 'displays all main links on the navbar and puts custom links in the dropdown' do
      sign_in_user coach.user, referrer: review_course_path(coached_course)

      expect(page).to have_link('Admin', href: '/school')
      expect(page).to have_link('Dashboard', href: '/dashboard')
      expect(page).to have_link(custom_link_4.title, href: custom_link_4.url)

      # None of the custom links should be visible by default.
      expect(page).not_to have_link(
        custom_link_3.title,
        href: custom_link_3.url
      )
      expect(page).not_to have_link(
        custom_link_2.title,
        href: custom_link_2.url
      )
      expect(page).not_to have_link(
        custom_link_1.title,
        href: custom_link_1.url
      )

      within('div[title="Show more links"]') do
        find('span', text: 'More').click
      end

      # All the custom links should now be displayed.
      expect(page).to have_link(custom_link_3.title, href: custom_link_3.url)
      expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)
      expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)
    end
  end

  context 'when the user is a coach in multiple course and a student in another' do
    before do
      # Enroll one coach as a "course" coach.
      create :faculty_course_enrollment, faculty: coach, course: coached_course
      create :faculty_course_enrollment,
             faculty: coach,
             course: another_coached_course
    end

    scenario 'user can switch between courses' do
      sign_in_user coach.user, referrer: review_course_path(coached_course)

      click_button coached_course.name

      expect(page).to have_link(
        student.course.name,
        href: curriculum_course_path(student.course)
      )

      # Smart links
      expect(page).to have_link(
        another_coached_course.name,
        href: review_course_path(another_coached_course)
      )
    end

    scenario 'coach can access other course links' do
      sign_in_user coach.user, referrer: review_course_path(coached_course)

      expect(page).to have_link(
        'Curriculum',
        href: curriculum_course_path(coached_course)
      )

      expect(page).to have_link(
        'Review',
        href: review_course_path(coached_course)
      )

      expect(page).to have_link(
        'Students',
        href: students_course_path(coached_course)
      )

      expect(page).to have_text(coach.user.name)

      expect(page).to have_link('Sign Out', href: destroy_user_session_path)
    end
  end
end
