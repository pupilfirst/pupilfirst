require 'rails_helper'

feature "Course students list", js: true do
  include UserSpecHelper

  # The basics
  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:course_coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }

  # Create few teams
  let!(:team_1) { create :startup, level: level_1 }
  let!(:team_2) { create :startup, level: level_2 }
  let!(:team_3) { create :startup, level: level_2 }
  let!(:team_4) { create :startup, level: level_3 }
  let!(:team_5) { create :startup, level: level_3 }
  let!(:team_6) { create :startup, level: level_3 }

  before do
    create :faculty_course_enrollment, faculty: course_coach, course: course
    10.times do
      create :startup, level: level_3
    end

    create :faculty_startup_enrollment, faculty: team_coach, startup: team_6
  end

  scenario 'coach checks the complete list of students' do
    sign_in_user course_coach.user, referer: students_course_path(course)

    expect(page).to have_button('All Levels')

    teams_sorted_by_name = course.startups.order(:name).to_a

    # Check if the first ten teams are listed
    expect(page).to have_text(teams_sorted_by_name[0].name)
    expect(page).to have_text(teams_sorted_by_name[1].name)
    expect(page).to have_text(teams_sorted_by_name[9].name)

    # Check if teams in next page are not listed
    expect(page).to_not have_text(teams_sorted_by_name[10].name)
    expect(page).to_not have_text(teams_sorted_by_name[11].name)

    click_button('Load More...')

    expect(page).to have_text(teams_sorted_by_name[10].name)
    expect(page).to have_text(teams_sorted_by_name[11].name)

    # Check if founders are listed
    course.startups.each do |startup|
      expect(page).to have_text(startup.founders.first.name)
    end

    # Check levels of few teams
    within("div[aria-label='team-level-info-#{team_1.id}']") do
      expect(page).to have_text('1')
    end

    within("div[aria-label='team-level-info-#{team_2.id}']") do
      expect(page).to have_text('2')
    end

    within("div[aria-label='team-level-info-#{team_5.id}']") do
      expect(page).to have_text('3')
    end
  end

  scenario 'coach searches for and filters students by level' do
    sign_in_user course_coach.user, referer: students_course_path(course)

    expect(page).to have_text(course.startups.order('name').first.name)

    # Filter by level
    click_button 'All Levels'
    click_button "Level 1 | #{level_1.name}"

    expect(page).not_to have_text(team_5.name)
    expect(page).to have_text(team_1.name)

    click_button "Level 1 | #{level_1.name}"
    click_button "Level 2 | #{level_2.name}"

    expect(page).not_to have_text("Level 1 | #{level_1.name}")

    expect(page).to have_text(team_3.name)
    expect(page).not_to have_text(team_1.name)

    # Search for a student in the filtered level
    student_name = team_3.founders.first.name
    fill_in 'student_search', with: student_name
    click_button 'Search'

    expect(page).to have_text(student_name)
    expect(page).to_not have_text(team_2.name)

    # Clear the search
    click_button 'clear-student-search'

    expect(page).to have_text(team_2.name)
    expect(page).to have_text(team_3.name)

    # Switch to level which will have pagination
    click_button "Level 2 | #{level_2.name}"
    click_button "Level 3 | #{level_3.name}"
    expect(page).to_not have_text(team_1.name)

    click_button('Load More...')
    expect(page).to have_text(team_6.name)

    # Clear the level filter
    click_button "Level 3 | #{level_3.name}"
    click_button 'All Levels'

    click_button('Load More...')
    expect(page).to have_text(team_1.name)
    expect(page).to have_text(team_3.name)
    expect(page).to have_text(team_6.name)
  end

  scenario 'team coach only has assigned teams in the students list' do
    sign_in_user team_coach.user, referer: students_course_path(course)

    expect(page).to have_text(team_6.name)
    expect(page).to_not have_text(team_1.name)
  end
end
