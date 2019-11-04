require 'rails_helper'

feature "Course students list", js: true do
  include UserSpecHelper

  # The basics
  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:coach) { create :faculty, school: school }

  # Create few teams
  let!(:team_1) { create :startup, level: level_1 }
  let!(:team_2) { create :startup, level: level_2 }
  let!(:team_3) { create :startup, level: level_2 }
  let!(:team_4) { create :startup, level: level_3 }
  let!(:team_5) { create :startup, level: level_3 }
  let!(:team_6) { create :startup, level: level_3 }

  before do
    create :faculty_course_enrollment, faculty: coach, course: course
  end

  scenario 'coach checks the complete list of students' do
    sign_in_user coach.user, referer: students_course_path(course)

    expect(page).to have_button('All Levels')

    # Check if teams from all levels are listed
    expect(page).to have_text(team_1.name)
    expect(page).to have_text(team_3.name)
    expect(page).to have_text(team_6.name)

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
    sign_in_user coach.user, referer: students_course_path(course)

    expect(page).to have_text(team_1.name)

    # Filter by level
    click_button 'All Levels'
    click_button "Level 1 | #{level_1.name}"

    expect(page).to have_text(team_1.name)
    expect(page).not_to have_text(team_5.name)

    click_button "Level 1 | #{level_1.name}"
    click_button "Level 3 | #{level_3.name}"

    expect(page).not_to have_text("Level 1 | #{level_1.name}")

    expect(page).to have_text(team_5.name)
    expect(page).not_to have_text(team_1.name)
  end
end
