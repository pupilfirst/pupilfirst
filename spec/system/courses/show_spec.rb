require "rails_helper"

feature "Public view of Course", js: true do
  include UserSpecHelper

  let(:school) { create :school, :current }
  let(:school_2) { create :school }
  let(:public_course) { create :course, school: school, public_signup: true }
  let(:private_course) { create :course, school: school }
  let(:public_signup_course_in_school_2) do
    create :course, school: school_2, public_signup: true
  end
  let(:new_about) { Faker::Lorem.paragraph }

  context "when the course has public signup enabled" do
    before do
      # Update course description
      public_course.update!(about: new_about)
    end

    scenario "non-signed-in user can see the course details" do
      visit course_path(public_course)

      expect(page).to have_content(public_course.name)
      expect(page).to have_link(
        "Apply Now",
        href: apply_course_path(public_course)
      )
      expect(page).to have_text(public_course.highlights.first["title"])
      expect(page).to have_text(public_course.highlights.last["description"])
    end

    scenario "non-signed-in user can't see details of public courses from other schools" do
      visit course_path(public_signup_course_in_school_2)

      expect(page).to have_text("The page you were looking for doesn't exist!")
      expect(page).not_to have_content(public_signup_course_in_school_2.name)
    end
  end

  context "when the course has public preview enabled" do
    let(:course) do
      create :course, :with_cohort, school: school, public_preview: true
    end
    let(:level) { create :level, course: course }
    let(:student) { create :student, cohort: course.cohorts.first }

    scenario "non-signed-in user can see a link to preview the course" do
      visit course_path(course)

      expect(page).to have_content(course.name)
      expect(page).to have_link(
        "Preview Course",
        href: curriculum_course_path(course)
      )
    end

    scenario "signed-in student sees a link to continue the course" do
      sign_in_user student.user, referrer: course_path(course)

      expect(page).to have_link(
        "Continue Course",
        href: curriculum_course_path(course)
      )
    end
  end

  context "when the course is private" do
    let(:course) { create :course, school: school, about: about }
    let(:about) { Faker::Lorem.paragraph }

    scenario "non-signed-in user attempting to view course details" do
      visit course_path(course)

      expect(page).to have_content(course.name)
      expect(page).to have_content(course.about)
      expect(page).not_to have_link(
        "Apply Now",
        href: apply_course_path(course)
      )
      expect(page).not_to have_link("Preview Course")
    end
  end
end
