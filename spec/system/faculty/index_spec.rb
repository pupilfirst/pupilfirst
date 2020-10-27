require 'rails_helper'

feature 'Connect to featured coaches', js: true do
  include UserSpecHelper

  let(:startup) { create :startup }
  let(:school) { startup.school }
  let(:school_admin) { create :school_admin, school: school }
  let(:student) { startup.founders.first }
  let(:course) { startup.course }
  let(:enrolled_hidden_coach) { create :faculty, school: school, public: false }

  before do
    create :faculty_course_enrollment, faculty: enrolled_hidden_coach, course: course
  end

  context 'when there are no featured coaches' do
    scenario 'A member of the public attempts to view the coaches page' do
      visit coaches_index_path

      expect(page).to have_content("The page you were looking for doesn't exist")
    end
  end

  context 'when there are one or more featured coaches' do
    let(:coach) { create :faculty, school: school, public: true }
    let!(:unenrolled_coach) { create :faculty, school: school, public: true }

    before do
      create :faculty_course_enrollment, faculty: coach, course: course
      unenrolled_coach.user.update!(about: Faker::Lorem.paragraph)
    end

    scenario 'A member of the public visits the coaches page' do
      visit coaches_index_path

      # There should be two coach cards.
      expect(page).to have_content(coach.name)
      expect(page).to have_content(unenrolled_coach.name)
      expect(page).not_to have_content(enrolled_hidden_coach.name)

      # There should be only one 'About' button
      click_link 'About'
      expect(page).to have_content(unenrolled_coach.about)

      # The user should be able to close the overlay.
      find('a[aria-label="Close"').click
      expect(page).not_to have_content(unenrolled_coach.about)
    end

    scenario 'A student visits the coaches page' do
      sign_in_user(student.user, referrer: coaches_index_path)

      # There should be only one coach card visible.
      expect(page).to have_content(coach.name)

      # The second should be visible once the filter is removed.
      click_button "Remove selection: #{course.name}"
      expect(page).to have_content(unenrolled_coach.name)

      # The third coach should still not be visible.
      expect(page).not_to have_content(enrolled_hidden_coach.name)
    end

    context 'when featured coaches are in a mix of public and private courses' do
      let(:course_2) { create :course, school: school, featured: false }
      let(:course_3) { create :course, school: school, featured: false }
      let(:startup_2) { create :startup, course: course_2 }
      let!(:student_2) { create :founder, startup: startup_2 }
      let(:coach_2) { create :faculty, school: school, public: true }
      let(:coach_3) { create :faculty, school: school, public: true }

      before do
        create :faculty_course_enrollment, faculty: coach_2, course: course_2
        create :faculty_course_enrollment, faculty: coach_3, course: course_3
      end

      scenario 'A member of the public uses the filter on the featured coaches page' do
        visit coaches_index_path

        # All featured coaches should be visible.
        expect(page).to have_content(coach.name)
        expect(page).to have_content(unenrolled_coach.name)
        expect(page).to have_content(coach_2.name)
        expect(page).to have_content(coach_3.name)

        # Only the public course should be visible in the filter.
        fill_in 'Filter by', with: 'teaches'

        expect(page).to have_button("Teaches Course: #{course.name}")
        expect(page).not_to have_button("Teaches Course: #{course_2.name}")
        expect(page).not_to have_button("Teaches Course: #{course_3.name}")

        click_button "Teaches Course: #{course.name}"

        # Only coaches in the selected course should be visible.
        expect(page).to have_content(coach.name)
        expect(page).not_to have_content(unenrolled_coach.name)
        expect(page).not_to have_content(coach_2.name)
        expect(page).not_to have_content(coach_3.name)

        click_button "Remove selection: #{course.name}"
        fill_in 'Filter by', with: unenrolled_coach.name
        click_button "Name Like: #{unenrolled_coach.name}"

        # Only coaches with matching name should be shown.
        expect(page).to have_content(unenrolled_coach.name)
        expect(page).not_to have_content(coach.name)
        expect(page).not_to have_content(coach_2.name)
        expect(page).not_to have_content(coach_3.name)
      end

      scenario 'A student uses the filter on the featured coaches page' do
        sign_in_user(student_2.user, referrer: coaches_index_path)

        # A student enrolled in a private course should still load the page with the private course in the filter.
        expect(page).to have_content(coach_2.name)
        expect(page).not_to have_content(coach.name)
        expect(page).not_to have_content(unenrolled_coach.name)
        expect(page).not_to have_content(coach_3.name)

        click_button "Remove selection: #{course_2.name}"
        fill_in 'Filter by', with: 'teaches'

        expect(page).to have_button("Teaches Course: #{course.name}")
        expect(page).to have_button("Teaches Course: #{course_2.name}")
        expect(page).not_to have_button("Teaches Course: #{course_3.name}")
      end

      scenario 'A coach uses the filter on the featured coaches page' do
        sign_in_user(coach.user, referrer: coaches_index_path)

        # Only public courses should be listed in the filter.
        fill_in 'Filter by', with: 'teaches'

        expect(page).to have_button("Teaches Course: #{course.name}")
        expect(page).not_to have_button("Teaches Course: #{course_2.name}")
        expect(page).not_to have_button("Teaches Course: #{course_3.name}")
      end

      scenario 'An admin uses the filter on the featured coaches page' do
        sign_in_user(school_admin.user, referrer: coaches_index_path)

        # All courses should be listed in the filter.
        fill_in 'Filter by', with: 'teaches'

        expect(page).to have_button("Teaches Course: #{course.name}")
        expect(page).to have_button("Teaches Course: #{course_2.name}")
        expect(page).to have_button("Teaches Course: #{course_3.name}")
      end
    end
  end
end
