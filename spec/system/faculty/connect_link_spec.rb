require 'rails_helper'

feature 'Connect Link' do
  include UserSpecHelper

  let(:startup) { create :startup }
  let(:school) { startup.school }
  let(:school_admin) { create :school_admin, school: school }
  let(:course) { startup.course }
  let(:founder) { startup.founders.first }
  let(:coach) { create :faculty, school: school, public: true, connect_link: Faker::Internet.url }
  let!(:unenrolled_coach) { create :faculty, school: school, public: true, connect_link: Faker::Internet.url }
  let(:enrolled_hidden_coach) { create :faculty, school: school, public: false, connect_link: Faker::Internet.url }

  before do
    create :faculty_course_enrollment, faculty: coach, course: course
    create :faculty_course_enrollment, faculty: enrolled_hidden_coach, course: course
  end

  scenario 'A member of the public visits coaches page' do
    visit coaches_index_path

    # There should be a two coach cards.
    expect(page).to have_selector('.faculty-card', count: 2)

    # There should be no connect link on the page, since user isn't signed in.
    expect(page).not_to have_selector('.connect-link')
  end

  scenario 'Student visits coaches page' do
    sign_in_user(founder.user, referer: coaches_index_path)

    # There should be a two coach cards.
    expect(page).to have_selector('.faculty-card', count: 2)

    # ...and only one connect link.
    expect(page).to have_link('Connect', href: coach.connect_link)
    expect(page).not_to have_link('Connect', href: unenrolled_coach.connect_link)
    expect(page).not_to have_link('Connect', href: enrolled_hidden_coach.connect_link)
  end

  scenario 'Coach visits coaches page' do
    sign_in_user(coach.user, referer: coaches_index_path)

    # There should be a two coach cards.
    expect(page).to have_selector('.faculty-card', count: 2)

    # Both cards should have connect links.
    expect(page).to have_link('Connect', href: coach.connect_link)
    expect(page).to have_link('Connect', href: unenrolled_coach.connect_link)
    expect(page).not_to have_link('Connect', href: enrolled_hidden_coach.connect_link)
  end

  scenario 'school admin visits coaches page' do
    sign_in_user(school_admin.user, referer: coaches_index_path)

    # Both cards should have connect links.
    expect(page).to have_link('Connect', href: coach.connect_link)
    expect(page).to have_link('Connect', href: unenrolled_coach.connect_link)
    expect(page).not_to have_link('Connect', href: enrolled_hidden_coach.connect_link)
  end
end
