require 'rails_helper'

feature "Public view of Course", js: true do
  include UserSpecHelper

  # The basics.
  let(:school) { create :school, :current }
  let(:school_2) { create :school }
  let(:public_course) { create :course, school: school, public_signup: true }
  let(:private_course) { create :course, school: school }
  let(:public_course_in_school_2) { create :course, school: school_2, public_signup: true }
  let(:new_about) { Faker::Lorem.paragraph }

  context 'when public user visits a public course' do
    before do
      # Update course description
      public_course.update!(about: new_about)
    end

    scenario 'He can see the course name and link to apply' do
      visit course_path(public_course)

      expect(page).to have_content(public_course.name)
      expect(page).to have_link("Apply Now", href: apply_course_path(public_course))
    end

    scenario 'He can see the course about when an about exists' do
      visit course_path(public_course)

      expect(page).to have_content(public_course.name)
      expect(page).to have_content(new_about)
    end

    scenario "He can't see public courses in other school" do
      visit course_path(public_course_in_school_2)

      expect(page).to have_text("The page you were looking for doesn't exist!")
      expect(page).not_to have_content(public_course_in_school_2.name)
    end
  end

  context 'when public user visits a non public course' do
    scenario 'The page should render' do
      visit course_path(private_course)

      expect(page).to have_content(private_course.name)
      expect(page).not_to have_link("Apply Now", href: apply_course_path(public_course))
    end
  end
end
