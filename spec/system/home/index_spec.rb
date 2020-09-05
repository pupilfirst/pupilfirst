require 'rails_helper'

feature 'Index spec', js: true do
  include UserSpecHelper
  # Setup a course with founders and target for community.
  let(:school) { create :school, :current }

  let!(:course_1) { create :course, school: school, featured: true }
  let!(:course_2) { create :course, school: school, featured: true, public_signup: true }
  let!(:course_3) { create :course, school: school, featured: false, public_signup: true }
  let!(:course_4) { create :course, school: school, featured: false }

  context 'When an user visits a school with an about' do
    before do
      school.update!(about: Faker::Lorem.sentence)
    end

    scenario 'When an user visits a school' do
      visit root_path

      expect(page).to have_text(school.name)
      expect(page).to have_text(school.about)
      expect(page).to have_text("Featured Courses")

      within("div[aria-label=\"#{course_1.name}\"]") do
        expect(page).to have_text(course_1.name)
        expect(page).to have_text(course_1.description)
        expect(page).to have_link("Learn more", href: course_path(course_1))
      end

      within("div[aria-label=\"#{course_2.name}\"]") do
        expect(page).to have_text(course_2.name)
        expect(page).to have_text(course_2.description)
        expect(page).to have_link("Get started", href: course_path(course_2))
      end

      expect(page).not_to have_text(course_3.name)
      expect(page).not_to have_text(course_4.name)

      expect(page).not_to have_link("Get started", href: course_path(course_3))
      expect(page).not_to have_link("Learn more", href: course_path(course_4))
    end
  end

  context 'When an user visits a school without an about' do
    scenario 'Page will render correctly' do
      visit root_path

      expect(page).to have_text(school.name)

      within("div[aria-label=\"#{course_1.name}\"]") do
        expect(page).to have_text(course_1.name)
        expect(page).to have_link("Learn more", href: course_path(course_1))
      end
    end
  end

  context 'When an user visits a school without any featured courses' do
    let!(:course_1) { create :course, school: school, featured: false }
    let!(:course_2) { create :course, school: school, featured: false }

    scenario 'Featured course section will be hidden' do
      visit root_path

      expect(page).to have_text(school.name)
      expect(page).not_to have_text("Featured Courses")

      expect(page).not_to have_text(course_1.name)
      expect(page).not_to have_text(course_2.name)
      expect(page).not_to have_text(course_3.name)
      expect(page).not_to have_text(course_4.name)
    end
  end

  context 'when user is a student in a course' do
    let(:level) { create :level, :one, course: course_1 }
    let(:team) { create :team, level: level }
    let(:student) { create :student, startup: team }

    scenario 'students can jump directly into the course curriculum' do
      sign_in_user student.user, referrer: root_path

      expect(page).to have_link('View Course', href: curriculum_course_path(course_1))
    end
  end
end
