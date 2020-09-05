require 'rails_helper'

feature 'Course students list', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper

  # The basics
  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:course_coach) { create :faculty, school: school }
  let(:team_coach) { create :faculty, school: school }

  # Create few teams
  let!(:team_1) { create :startup, level: level_1, name: 'Zucchini', tag_list: ['starts with z', 'vegetable'] } # This will always be around the bottom of the list.
  let!(:team_2) { create :startup, level: level_2, name: 'Asparagus', tag_list: ['vegetable'] } # This will always be around the top.
  let!(:team_3) { create :startup, level: level_2, name: 'Banana' }
  let!(:team_4) { create :startup, level: level_3, name: 'Blueberry' }
  let!(:team_5) { create :startup, level: level_3, name: 'Cherry' }
  let!(:team_6) { create :startup, level: level_3, name: 'Elderberry' }

  before do
    create :faculty_course_enrollment, faculty: course_coach, course: course

    10.times do
      create :startup, level: level_3, name: "C #{Faker::Lorem.word} #{rand(10)}" # These will be in the middle of the list.
    end

    create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach, startup: team_6
  end

  scenario 'coach checks the complete list of students' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

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

    # Check number of students in levels
    within("div[aria-label='Students level-wise distribution']") do
      expect(page).to have_selector('.student-distribution__pill', count: 3)
    end

    within("div[aria-label='Students in level 1']") do
      expect(page).to have_text('1')
    end

    within("div[aria-label='Students in level 2']") do
      expect(page).to have_text('2')
    end

    within("div[aria-label='Students in level 3']") do
      expect(page).to have_text('3')
    end

    # Hover over a level to get percentage data
    students_in_course = Founder.where(startup: course.startups).count
    students_in_l2 = Founder.where(startup_id: [team_2.id, team_3.id]).count
    percentage_students_in_l2 = students_in_l2 / students_in_course.to_f * 100

    within("div[aria-label='Students in level 2']") do
      find('.tooltip__trigger').hover
    end

    expect(page).to have_text("Percentage: #{percentage_students_in_l2}")
    expect(page).to have_text('Teams: 2')
    expect(page).to have_text("Students: #{students_in_l2}")
  end

  scenario 'coach searches for and filters students by level' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    expect(page).to have_text(course.startups.order('name').first.name)

    # Filter by level
    fill_in 'filter', with: 'level'
    click_button "Level 1: #{level_1.name}"

    expect(page).not_to have_text(team_5.name)
    expect(page).to have_text(team_1.name)

    fill_in 'filter', with: 'level'
    click_button "Level 2: #{level_2.name}"

    expect(page).not_to have_text("Level 1 | #{level_1.name}")

    expect(page).to have_text(team_3.name)
    expect(page).not_to have_text(team_1.name)

    # Search for a student in the filtered level
    student_name = team_3.founders.first.name
    fill_in 'filter', with: student_name
    click_button "Name or Email: #{student_name}"

    expect(page).to have_text(student_name)
    expect(page).to_not have_text(team_2.name)

    # Clear the filter
    find("button[title='Remove selection: #{student_name}']").click

    expect(page).to have_text(team_2.name)
    expect(page).to have_text(team_3.name)

    # Switch to level which will have pagination
    fill_in 'filter', with: 'level'
    click_button "Level 3: #{level_3.name}"

    expect(page).to_not have_text(team_2.name)

    click_button('Load More...')

    expect(page).to have_text(team_6.name)

    # Clear the level filter
    find("button[title='Remove selection: #{level_3.name}']").click

    expect(page).to have_text(team_2.name)

    click_button('Load More...')

    expect(page).to have_text(team_1.name)
    expect(page).to have_text(team_5.name)
    expect(page).to have_text(team_6.name)

    # Filter by level using student distribution
    find("div[aria-label='Students in level 1']").click

    expect(page).to_not have_text('Elderberry')
    expect(page).to have_text('Zucchini')
  end

  scenario 'team coach only has assigned teams in the students list' do
    sign_in_user team_coach.user, referrer: students_course_path(course)

    expect(page).to have_text(team_6.name)
    expect(page).to_not have_text(team_3.name)

    # Team coach can remove the default filter to see all students.
    find('button[title="Remove selection: Me"').click

    expect(page).to have_text(team_2.name)

    click_button('Load More...')

    expect(page).to have_text(team_3.name)
  end

  context 'when there are more than one team coaches' do
    let(:another_team_coach) { create :faculty, school: school }

    before do
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: another_team_coach, startup: team_2
    end

    scenario "one team coach can use the filter to see another coach's students" do
      sign_in_user team_coach.user, referrer: students_course_path(course)

      expect(page).to have_text(team_6.name)
      expect(page).to_not have_text(team_2.name)

      fill_in 'filter', with: another_team_coach.name
      click_button "Assigned to: #{another_team_coach.name}"

      expect(page).not_to have_text(team_6.name)
      expect(page).to have_text(team_2.name)
    end
  end

  scenario 'course coach checks list of directly assigned coaches' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    click_button('Load More...')

    expected_initials = team_coach.name.split(' ')[0..1]
      .map { |name_fragment| name_fragment[0] }
      .map(&:capitalize).join

    within("div[aria-label='Info of team #{team_6.id}']") do
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
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach_2, startup: team_6
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach_3, startup: team_6
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach_4, startup: team_6
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: team_coach_5, startup: team_6
    end

    scenario 'course coach checks names of coaches hidden from main list' do
      possible_names = [team_coach.name, team_coach_2.name, team_coach_3.name, team_coach_4.name, team_coach_5.name]

      sign_in_user course_coach.user, referrer: students_course_path(course)

      click_button('Load More...')

      within("div[aria-label='Info of team #{team_6.id}']") do
        find('.tooltip__trigger', text: '+2').hover
      end

      find('.tooltip__bubble').text.strip.split("\n").each do |name|
        expect(name).to be_in(possible_names)
      end
    end
  end

  context 'when all students have completed a level' do
    # Create new levels with no students
    let!(:level_4) { create :level, :four, course: course }
    let!(:level_5) { create :level, :five, course: course }

    before do
      level_1.startups.each { |s| s.update!(level_id: level_2.id) }
    end

    scenario 'level shows completed icon instead of number of students' do
      sign_in_user course_coach.user, referrer: students_course_path(course)

      within("div[aria-label='Students in level 1']") do
        expect(page).to_not have_text('0')
        expect(page).to have_selector('.i-check-solid')
      end

      within("div[aria-label='Students in level 4']") do
        expect(page).to have_text('0')
      end
    end
  end

  context 'when there are locked levels in course' do
    let!(:locked_level_4) { create :level, :four, course: course, unlock_at: 5.days.from_now }
    let!(:locked_level_5) { create :level, :five, course: course, unlock_at: 5.days.from_now }

    scenario 'it is shown as locked in student level wise distribution' do
      sign_in_user course_coach.user, referrer: students_course_path(course)

      within("div[aria-label='Students in level 2']") do
        expect(page).to_not have_selector('.student-distribution__pill--locked')
      end

      within("div[aria-label='Students in level 4']") do
        expect(page).to have_text('0')
        expect(page).to have_selector('.student-distribution__pill--locked')
      end
    end
  end

  scenario 'filtering by coach updates the student distribution data' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    within("div[aria-label='Students in level 1']") do
      expect(page).to have_text('1')
    end

    within("div[aria-label='Students in level 2']") do
      expect(page).to have_text('2')
    end

    within("div[aria-label='Students in level 3']") do
      expect(page).to have_text('3')
    end

    fill_in 'filter', with: team_coach.name
    click_button "Assigned to: #{team_coach.name}"

    within("div[aria-label='Students in level 1']") do
      expect(page).to have_selector('svg.i-check-solid')
    end

    within("div[aria-label='Students in level 2']") do
      expect(page).to have_selector('svg.i-check-solid')
    end

    within("div[aria-label='Students in level 3']") do
      expect(page).to have_text('1')
    end
  end

  context 'when some students have coach notes' do
    let(:author) { course_coach.user }

    before do
      team_2.founders.each do |student|
        create :coach_note, author: author, student: student
      end
    end

    scenario 'filtering by coach notes updates list of students and distribution bar' do
      sign_in_user course_coach.user, referrer: students_course_path(course)

      expect(page).to have_text(team_2.name)
      expect(page).to have_text(team_3.name)

      within("div[aria-label='Students in level 1']") do
        expect(page).to have_text('1')
      end

      within("div[aria-label='Students in level 2']") do
        expect(page).to have_text('2')
      end

      within("div[aria-label='Students in level 3']") do
        expect(page).to have_text('3')
      end

      fill_in 'filter', with: 'has notes'
      click_button 'Coach Notes: Has notes'

      expect(page).not_to have_text(team_3.name)
      expect(page).to have_text(team_2.name)

      within("div[aria-label='Students in level 1']") do
        expect(page).to have_selector('svg.i-check-solid')
      end

      within("div[aria-label='Students in level 2']") do
        expect(page).to have_text('1')
      end

      within("div[aria-label='Students in level 3']") do
        expect(page).to have_text('0')
      end

      fill_in 'filter', with: 'does not have notes'
      click_button 'Coach Notes: Does not have notes'

      expect(page).not_to have_text(team_2.name)
      expect(page).to have_text(team_3.name)

      within("div[aria-label='Students in level 1']") do
        expect(page).to have_text('1')
      end

      within("div[aria-label='Students in level 2']") do
        expect(page).to have_text('1')
      end

      within("div[aria-label='Students in level 3']") do
        expect(page).to have_text('3')
      end
    end

    scenario 'adding note to all students in a team should refresh list with "does not have notes" filter' do
      remaining_student = team_3.founders.first
      other_students = team_3.founders.where.not(id: remaining_student)

      other_students.each do |student|
        create :coach_note, author: author, student: student
      end

      sign_in_user course_coach.user, referrer: students_course_path(course)
      fill_in 'filter', with: 'does not have notes'
      click_button 'Coach Notes: Does not have notes'

      within("div[aria-label='Students in level 2']") do
        expect(page).to have_text('1')
      end

      click_link remaining_student.name
      add_markdown('This is a note.')
      click_button 'Save Note'

      expect(page).to have_text('Note added successfully')

      find('button[title="Close student report"]').click

      within("div[aria-label='Students in level 2']") do
        expect(page).to have_text('0')
      end

      expect(page).not_to have_text(remaining_student.name)
    end
  end

  scenario 'coach filters students by tags applied to their team' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    team_in_first_page = course.startups.where.not(id: team_2.id).order(:name).first

    expect(page).to have_text(team_in_first_page.name)

    within("div[aria-label='Students in level 1']") do
      expect(page).to have_text('1')
    end

    within("div[aria-label='Students in level 2']") do
      expect(page).to have_text('2')
    end

    within("div[aria-label='Students in level 3']") do
      expect(page).to have_text('3')
    end

    fill_in 'filter', with: 'vegetable'
    click_button 'Tagged with: vegetable'

    # The filter should affect the distribution...
    within("div[aria-label='Students in level 2']") do
      expect(page).to have_text('1')
    end

    within("div[aria-label='Students in level 1']") do
      expect(page).to have_text('1')
    end

    within("div[aria-label='Students in level 3']") do
      expect(page).to have_text('0')
    end

    # ...and the students listed below.
    expect(page).not_to have_text(team_in_first_page.name)
    expect(page).to have_text('Asparagus')
    expect(page).to have_text('Zucchini')

    fill_in 'filter', with: 'z'
    click_button 'Tagged with: starts with z'

    within("div[aria-label='Students in level 2']") do
      expect(page).to have_text('0')
    end

    within("div[aria-label='Students in level 1']") do
      expect(page).to have_text('1')
    end

    expect(page).not_to have_text('Asparagus')
    expect(page).not_to have_text(team_in_first_page.name)
    expect(page).to have_text('Zucchini')
  end

  scenario 'coach searches student by email' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    teams_sorted_by_name = course.startups.order('name')
    team_of_student_to_search = teams_sorted_by_name[5]
    another_team = teams_sorted_by_name.first

    expect(page).to have_text(another_team.name)

    # Apply search by email filter
    student_email = team_of_student_to_search.founders.first.email
    fill_in 'filter', with: student_email
    click_button "Name or Email: #{student_email}"

    expect(page).not_to have_text(another_team.name)
    expect(page).to have_text(team_of_student_to_search.name)

    # Clear the filter
    find("button[title='Remove selection: #{student_email}']").click
    expect(page).to have_text(another_team.name)
  end
end
