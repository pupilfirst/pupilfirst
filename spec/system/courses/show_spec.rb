require 'rails_helper'

feature 'Public view of Course', js: true do
  include UserSpecHelper

  let(:school) { create :school, :current }

  context 'when the course has public signup enabled' do
    let(:school_2) { create :school }
    let!(:course) { create :course, school: school, public_signup: true }

    let(:public_signup_course_in_school_2) do
      create :course, school: school_2, public_signup: true
    end

    scenario 'non-signed-in user can see the course name and link to apply' do
      visit course_path(course)

      expect(page).to have_content(course.name)
      expect(page).to have_link('Apply Now', href: apply_course_path(course))
    end

    scenario "non-signed-in user can't see details of public courses from other schools" do
      visit course_path(public_signup_course_in_school_2)

      expect(page).to have_text("The page you were looking for doesn't exist!")
      expect(page).not_to have_content(public_signup_course_in_school_2.name)
    end
  end

  context 'when the course has public preview enabled' do
    let(:course) { create :course, school: school, public_preview: true }

    scenario 'non-signed-in user can see a link to preview the course' do
      visit course_path(course)

      expect(page).to have_content(course.name)
      expect(page).to have_link(
        'Preview Course',
        href: curriculum_course_path(course)
      )
    end
  end

  context 'when the course is private' do
    let(:course) { create :course, school: school, about: about }
    let(:about) { Faker::Lorem.paragraph }

    scenario 'non-signed-in user attempting to view course details' do
      visit course_path(course)

      expect(page).to have_content(course.name)
      expect(page).to have_content(about)
      expect(page).not_to have_link('Apply Now')
      expect(page).not_to have_link('Preview Course')
    end
  end
end
