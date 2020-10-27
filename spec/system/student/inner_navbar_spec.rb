require 'rails_helper'

feature 'Student Inner Navbar', js: true do
  include UserSpecHelper

  let(:student) { create :founder }
  let(:coach) { create :faculty, user: student.user }
  let(:coached_course) { create :course }
  let!(:c1_l1) { create :level, :one, course: student.course }
  let!(:c2_l1) { create :level, :one, course: coached_course }
  # let(:c1_l1_tg) { create :target_group, level: c1_l1 }
  # let(:c2_l1_tg) { create :target_group, level: c2_l1 }

  before do
    # Enroll the user as coach in one course.
    create :faculty_course_enrollment, faculty: coach, course: coached_course
  end

  context 'when the user is a coach in one course and a student in another' do
    scenario 'user can switch between the two courses' do
      sign_in_user(student.user, referrer: curriculum_course_path(coached_course))

      find('span', text: coached_course.name).click
      click_link(student.course.name)

      find('span', text: student.course.name).click
      expect(page).to have_link(coached_course.name)
    end
  end
end
