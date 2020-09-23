require 'rails_helper'

feature 'Connect to featured coaches', js: true do
  include UserSpecHelper

  let(:startup) { create :startup }
  let(:school) { startup.school }
  let(:school_admin) { create :school_admin, school: school }
  let(:student) { startup.founders.first }
  let(:course) { startup.course }
  let(:coach) { create :faculty, school: school, public: true, connect_link: Faker::Internet.url }
  let!(:unenrolled_coach) { create :faculty, school: school, public: true, connect_link: Faker::Internet.url }
  let(:enrolled_hidden_coach) { create :faculty, school: school, public: false, connect_link: Faker::Internet.url }

  before do
    create :faculty_course_enrollment, faculty: coach, course: course
    create :faculty_course_enrollment, faculty: enrolled_hidden_coach, course: course
  end

  scenario 'A member of the public visits coaches page' do
    visit coaches_index_path

    # There should be two coach cards.
    expect(page).to have_content(coach.name)
    expect(page).to have_content(unenrolled_coach.name)
    expect(page).not_to have_content(enrolled_hidden_coach.name)

    # There should be no connect link on the page, since user isn't signed in.
    expect(page).not_to have_link('Connect')
  end

  scenario 'Student visits coaches page' do
    sign_in_user(student.user, referrer: coaches_index_path)

    click_button "Remove selection: #{course.name}"

    # ...and connect links to coaches enrolled to his courses
    expect(page).to have_link('Connect', href: coach.connect_link)
    expect(page).not_to have_link('Connect', href: unenrolled_coach.connect_link)
    expect(page).not_to have_link('Connect', href: enrolled_hidden_coach.connect_link)
  end

  scenario 'Coach visits coaches page' do
    sign_in_user(coach.user, referrer: coaches_index_path)

    # There should be two coach cards.
    expect(page).to have_content(coach.name)
    expect(page).to have_content(unenrolled_coach.name)
    expect(page).not_to have_content(enrolled_hidden_coach.name)

    # Both cards should have connect links.
    expect(page).to have_link('Connect', href: coach.connect_link)
    expect(page).to have_link('Connect', href: unenrolled_coach.connect_link)
  end

  scenario 'school admin visits coaches page' do
    sign_in_user(school_admin.user, referrer: coaches_index_path)

    # There should be two coach cards.
    expect(page).to have_content(coach.name)
    expect(page).to have_content(unenrolled_coach.name)
    expect(page).not_to have_content(enrolled_hidden_coach.name)

    # Both cards should have connect links.
    expect(page).to have_link('Connect', href: coach.connect_link)
    expect(page).to have_link('Connect', href: unenrolled_coach.connect_link)
  end

  context 'course has no connect to coach feature enabled' do
    before do
      course.update!(can_connect: false)
    end

    scenario 'student visits coaches page' do
      sign_in_user(student.user, referrer: coaches_index_path)

      expect(page).to have_content(coach.name)
      click_button "Remove selection: #{course.name}"
      expect(page).to have_content(unenrolled_coach.name)

      # ...connect link for coach will not be displayed .
      expect(page).to_not have_link('Connect')
    end

    scenario 'admin visits coaches page' do
      sign_in_user(school_admin.user, referrer: coaches_index_path)

      expect(page).to have_content(coach.name)
      expect(page).to have_content(unenrolled_coach.name)

      # ...connect link for coach will still be displayed to an admin
      expect(page).to have_link('Connect', href: coach.connect_link)
    end
  end

  context 'user is enrolled in two courses of which one has connect feature disabled' do
    # Enroll student to another course in the same school with no connect feature
    let(:course_2) { create :course, school: school, can_connect: false }
    let(:startup_2) { create :startup, course: course_2 }
    let!(:student_2) { create :founder, startup: startup_2, user: student.user }
    let(:coach_2) { create :faculty, school: school, public: true, connect_link: Faker::Internet.url }

    before do
      create :faculty_course_enrollment, faculty: coach_2, course: course_2
    end

    scenario 'student visits the coaches page ' do
      sign_in_user(student.user, referrer: coaches_index_path)

      # There should be there coach cards, here.
      expect(page).to have_content(coach.name)
      click_button "Remove selection: #{course.name}"
      click_button "Remove selection: #{course_2.name}"
      expect(page).to have_content(unenrolled_coach.name)
      expect(page).to have_content(coach_2.name)

      # Can connect to coach in first course, but not the one with connect disabled.
      expect(page).to have_link('Connect', href: coach.connect_link)
      expect(page).not_to have_link('Connect', href: coach_2.connect_link)
    end
  end
end
