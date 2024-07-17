require "rails_helper"

feature "Student Inner Navbar", js: true do
  include UserSpecHelper

  let(:course) { create :course, :with_cohort }
  let!(:c1_l1) { create :level, :one, course: course }
  let(:student) { create :student, cohort: course.cohorts.first }

  let(:coach) { create :faculty, user: student.user }
  let(:coached_course) { create :course, :with_cohort }
  let!(:c2_l1) { create :level, :one, course: coached_course }

  before do
    # Enroll the user as coach in one course.
    create :faculty_cohort_enrollment,
           faculty: coach,
           cohort: coached_course.cohorts.first
  end

  context "when the user is a coach in one course and a student in another" do
    scenario "user can switch between the two courses" do
      sign_in_user(
        student.user,
        referrer: curriculum_course_path(coached_course)
      )

      find("span", text: coached_course.name).click

      click_link(student.course.name)

      find("span", text: student.course.name).click

      expect(page).to have_link(coached_course.name)
    end
  end
end
