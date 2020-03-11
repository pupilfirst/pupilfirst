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

  let!(:c1_level) { create :level, course: course_1 }
  let!(:c2_level) { create :level, course: course_2 }
  let!(:startup) { create :startup, level: c2_level }
  let!(:startup_2) { create :startup, level: c1_level }

  let!(:school_admin) { create :school_admin, school: school }

  before do
    create :faculty_course_enrollment, faculty: coach_1, course: course_1
    create :faculty_course_enrollment, faculty: coach_2, course: course_1
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_2, startup: startup_2
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_3, startup: startup
    create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_4, startup: startup
  end

  scenario 'school admin assigns faculty to a course' do
    sign_in_user school_admin.user, referer: school_course_coaches_path(course_1)

    # list all coaches
    expect(page).to have_text(coach_1.name)
    expect(page).to have_text(coach_2.name)
    expect(course_1.faculty.count).to eq(2)

    click_button 'Assign Coaches to Course'

    expect(page).to have_text('No coaches selected')

    find("div[title='Select #{coach_4.name}']").click

    click_button 'Add Course Coaches'

    within('div[aria-label="List of course coaches"]') do
      expect(page).to have_text(coach_4.name)
    end

    expect(course_1.reload.faculty.count).to eq(3)
  end

  scenario 'school admin removes a course coach' do
    sign_in_user school_admin.user, referer: school_course_coaches_path(course_1)

    expect(page).to have_text(coach_1.name)
    expect(coach_2.startups.count).to eq(1)

    accept_confirm do
      find("div[aria-label='Delete #{coach_2.name}']").click
    end

    expect(page).to_not have_text(coach_2.name)
    expect(course_1.faculty.count).to eq(1)
    expect(course_1.faculty.first).to eq(coach_1)
    # Removes the coach team enrollment as well
    expect(coach_2.startups.count).to eq(0)
  end

  scenario 'school admin checks teams assigned to a coach and deletes them' do
    sign_in_user school_admin.user, referer: school_course_coaches_path(course_2)

    expect(page).to have_text(coach_3.name)
    find("div[aria-label='coach-card-#{coach_3.id}']").click
    expect(page).to have_text('Students assigned to coach')
    expect(page).to have_text(coach_3.email)

    within("div[aria-label='Team #{startup.name}'") do
      expect(page).to have_text(startup.founders.first.name)
      expect(page).to have_text(startup.founders.last.name)
      expect(page).to have_text(startup.name)
    end

    accept_confirm do
      click_button "Delete #{startup.name}"
    end

    expect(page).to have_text('There are no teams assigned to this coach.')
    expect(coach_3.startups.count).to eq(0)
    expect(course_2.faculty.count).to eq(2)
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit school_course_coaches_path(course_1)
    expect(page).to have_text("Please sign in to continue.")
  end

  context 'when a coach is assigned as a team coach to students in multiple courses' do
    let!(:startup_3) { create :startup, level: c1_level }

    before do
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach_3, startup: startup_3
    end

    scenario 'user sees team assignments for coaches in the list' do
      sign_in_user school_admin.user, referer: school_course_coaches_path(course_2)

      # Check teams assigned to coach_3 in course 2
      find("div[aria-label='coach-card-#{coach_3.id}']").click
      expect(page).to have_text(startup.name)
      expect(page).not_to have_text(startup_3.name)
    end
  end
end
