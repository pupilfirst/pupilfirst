require 'rails_helper'

feature 'Course Coaches Index', js: true do
  include UserSpecHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:school_2) { create :school }
  let!(:course_1) { create :course, school: school }
  let!(:course_2) { create :course, school: school }

  let!(:coach_1) { create :faculty, school: school }
  let!(:coach_2) { create :faculty, school: school }
  let!(:coach_3) { create :faculty, school: school }
  let!(:coach_4) { create :faculty, school: school }
  let!(:coach_5) { create :faculty, school: school_2 }
  let!(:coach_6) { create :faculty, school: school, exited: true }

  let!(:level) { create :level, course: course_2 }
  let!(:startup) { create :startup, level: level }

  let!(:school_admin) { create :school_admin, school: school }

  before do
    FacultyCourseEnrollment.create(faculty: coach_1, course: course_1, safe_to_create: true)
    FacultyCourseEnrollment.create(faculty: coach_2, course: course_1, safe_to_create: true)
  end

  scenario 'school admin assigns faculty to a course' do
    sign_in_user school_admin.user, referer: school_course_coaches_path(course_1)

    # list all coaches
    expect(page).to have_text('Assign Coaches to Course')
    expect(page).to have_text(coach_1.name)
    expect(page).to have_text(coach_2.name)
    expect(course_1.faculty.count).to eq(2)

    click_button 'Assign Coaches to Course'

    expect(page).to have_text('None Selected')

    within '.select-list__group' do
      expect(page).to_not have_selector('.px-3', text: coach_5.name)
      expect(page).to_not have_selector('.px-3', text: coach_1.name)
      expect(page).to_not have_selector('.px-3', text: coach_2.name)
      find('.px-3', text: coach_3.name).click
    end

    click_button 'Add Course Coaches'

    within('div[aria-label="List of course coaches"]') do
      expect(page).to have_text(coach_3.name)
    end

    expect(course_1.reload.faculty.count).to eq(3)
  end

  before do
    FacultyStartupEnrollment.create(faculty: coach_3, startup: startup, safe_to_create: true)
  end

  scenario 'school admin assigns faculty to a course who already had a team enrollment' do
    sign_in_user school_admin.user, referer: school_course_coaches_path(course_2)

    # list all coaches
    expect(page).to have_text('Student/Team Coaches')
    expect(page).to have_text(coach_3.name)
    expect(page).to have_text(startup.name)
    expect(startup.faculty.count).to eq(1)

    click_button 'Assign Coaches to Course'

    within '.select-list__group' do
      expect(page).to_not have_text(coach_6.name)
      find('.px-3', text: coach_3.name).click
    end

    click_button 'Add Course Coaches'

    expect(page).to have_text('Course Coaches')
    expect(page).to_not have_text(startup.name)
    expect(startup.faculty.count).to eq(0)
  end

  scenario 'school admin removes a startup coach' do
    sign_in_user school_admin.user, referer: school_course_coaches_path(course_2)

    # list all coaches
    expect(page).to have_text('Student/Team Coaches')
    expect(page).to have_text(coach_3.name)
    expect(page).to have_text(startup.name)
    expect(startup.faculty.count).to eq(1)

    accept_confirm do
      find("div[aria-label='Delete #{coach_3.name}']").click
    end

    expect(page).to_not have_text(coach_3.name)
    expect(startup.faculty.count).to eq(0)
  end

  scenario 'school admin removes a course coach' do
    sign_in_user school_admin.user, referer: school_course_coaches_path(course_1)

    # list all coaches
    expect(page).to have_text('Course Coaches')
    expect(page).to have_text(coach_1.name)

    accept_confirm do
      find("div[aria-label='Delete #{coach_1.name}']").click
    end

    expect(page).to_not have_text(coach_1.name)
    expect(course_1.faculty.count).to eq(1)
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit school_course_coaches_path(course_1)
    expect(page).to have_text("Please sign in to continue.")
  end
end
