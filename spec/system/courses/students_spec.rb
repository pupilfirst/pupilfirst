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
  let!(:team_1) { create :startup, level: level_1, name: 'Zucchini' } # This will always be around the bottom of the list.
  let!(:team_2) { create :startup, level: level_2, name: 'Apple' } # This will always be around the top.
  let!(:team_3) { create :startup, level: level_2, name: 'Banana' }
  let!(:team_4) { create :startup, level: level_3, name: 'Blueberry' }
  let!(:team_5) { create :startup, level: level_3, name: 'Cherry' }
  let!(:team_6) { create :startup, level: level_3, name: 'Elderberry' }

  before do
    create :faculty_course_enrollment, faculty: course_coach, course: course

    10.times do
      create :startup, level: level_3, name: "C #{Faker::Lorem.word} #{rand(10)}" # These will be in the middle of the list.
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
    expect(page).to_not have_text(team_2.name)

    click_button('Load More...')
    expect(page).to have_text(team_6.name)

    # Clear the level filter
    click_button "Level 3 | #{level_3.name}"
    click_button 'All Levels'

    expect(page).to have_text(team_2.name)

    click_button('Load More...')

    expect(page).to have_text(team_1.name)
    expect(page).to have_text(team_5.name)
    expect(page).to have_text(team_6.name)
  end

  scenario 'team coach only has assigned teams in the students list' do
    sign_in_user team_coach.user, referer: students_course_path(course)

    expect(page).to have_text(team_6.name)
    expect(page).to_not have_text(team_1.name)
  end

  scenario 'course coach checks list of directly assigned coaches' do
    sign_in_user course_coach.user, referer: students_course_path(course)

    click_button('Load More...')

    team_6_entry = find("div[aria-label='team-card-#{team_6.id}']")

    expected_initials = team_coach.name.split(' ')[0..1]
      .map { |name_fragment| name_fragment[0] }
      .map(&:capitalize).join

    within(team_6_entry) do
      find('.tooltip__trigger', text: expected_initials).hover
    end

    expect(page).to have_text(team_coach.name)
  end

  context 'when there are more than 4 coaches directly assigned to a team' do
    let(:team_coach_2) { create :faculty, school: school }
    let(:team_coach_3) { create :faculty, school: school }
    let(:team_coach_4) { create :faculty, school: school }
    let(:team_coach_5) { create :faculty, school: school }

    before do
      create :faculty_startup_enrollment, faculty: team_coach_2, startup: team_6
      create :faculty_startup_enrollment, faculty: team_coach_3, startup: team_6
      create :faculty_startup_enrollment, faculty: team_coach_4, startup: team_6
      create :faculty_startup_enrollment, faculty: team_coach_5, startup: team_6
    end

    scenario 'course coach checks names of coaches hidden from main list' do
      possible_names = [team_coach.name, team_coach_2.name, team_coach_3.name, team_coach_4.name, team_coach_5.name]

      sign_in_user course_coach.user, referer: students_course_path(course)

      click_button('Load More...')

      team_6_entry = find("div[aria-label='team-card-#{team_6.id}']")

      within(team_6_entry) do
        find('.tooltip__trigger', text: '+2').hover
      end

      find('.tooltip__bubble').text.strip.split(', ').each do |name|
        expect(name).to be_in(possible_names)
      end
    end
  end
end
