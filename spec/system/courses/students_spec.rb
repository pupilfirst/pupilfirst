require 'rails_helper'

feature 'Course students list', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper

  # The basics
  let!(:school) { create :school, :current }
  let(:course) { create :course, school: school }
  let(:cohort) { create :cohort, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:level_3) { create :level, :three, course: course }
  let(:course_coach) { create :faculty, school: school }
  let(:student_coach) { create :faculty, school: school }

  # Create few students
  let!(:student_1) do
    create :student,
           level: level_1,
           tag_list: ['starts with z', 'vegetable'],
           cohort: cohort
  end # This will always be around the bottom of the list.
  let!(:student_2) do
    create :student, level: level_2, tag_list: ['vegetable'], cohort: cohort
  end # This will always be around the top.
  let!(:student_3) { create :student, level: level_2, cohort: cohort }
  let!(:student_4) { create :student, level: level_3, cohort: cohort }
  let!(:student_5) { create :student, level: level_3, cohort: cohort }
  let!(:student_6) { create :student, level: level_3, cohort: cohort }

  before do
    create :faculty_cohort_enrollment, faculty: course_coach, cohort: cohort
    student_1.user.update!(name: 'Zucchini', last_seen_at: 3.minutes.ago)
    student_2.user.update!(name: 'Asparagus')
    student_3.user.update!(name: 'Banana')
    student_4.user.update!(name: 'Blueberry')
    student_5.user.update!(name: 'Cherry')
    student_6.user.update!(name: 'Elderberry')

    30.times do
      user = create :user, name: "C #{Faker::Lorem.word} #{rand(10)}"

      # These will be in the middle of the list.
      create :student, cohort: cohort, level: level_3, user: user
    end

    create :faculty_student_enrollment,
           :with_cohort_enrollment,
           faculty: student_coach,
           student: student_6
  end

  scenario 'coach checks the complete list of students' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    click_button 'Order by Last Created'
    click_button 'Order by Name'

    students_sorted_by_name =
      course.students.joins(:user).order('users.name').to_a

    # Check if the first ten teams are listed
    expect(page).to have_text(students_sorted_by_name[0].name)
    expect(page).to have_text(students_sorted_by_name[10].name)
    expect(page).to have_text(students_sorted_by_name[19].name)

    # Check if teams in next page are not listed
    expect(page).to_not have_text(students_sorted_by_name[22].name)
    expect(page).to_not have_text(students_sorted_by_name[30].name)

    click_button('Load More...')

    expect(page).to have_text(students_sorted_by_name[22].name)
    expect(page).to have_text(students_sorted_by_name[30].name)

    # Check the last seen for the first student
    within("a[aria-label='Student #{student_1.name}']") do
      expect(page).to have_text('Last seen 3 minutes ago')
    end

    # Check the last seen for the second student
    within("a[aria-label='Student #{student_3.name}']") do
      expect(page).to have_text('This student has never signed in')
    end

    # Check levels of few students
    within("div[aria-label='student level info:#{student_1.id}']") do
      expect(page).to have_text('1')
    end

    within("div[aria-label='student level info:#{student_2.id}']") do
      expect(page).to have_text('2')
    end

    within("div[aria-label='student level info:#{student_5.id}']") do
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
    students_in_course = course.students.count
    students_in_l2 = 2
    percentage_students_in_l2 = students_in_l2 / students_in_course.to_f * 100

    within("div[aria-label='Students in level 2']") do
      find('.tooltip__trigger').hover
    end

    expect(page).to have_text(
      "Percentage: #{percentage_students_in_l2.round(1)}"
    )
    expect(page).to have_text("Students: #{students_in_l2}")
  end

  scenario 'coach searches for and filters students by level' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    click_button 'Order by Last Created'
    click_button 'Order by Name'

    expect(page).to have_text(
      course.students.joins(:user).order('users.name').first.name
    )

    # Filter by level
    fill_in 'Filter Resources', with: 'level'
    click_button "Pick Level: #{level_1.filter_display_name}"

    expect(page).not_to have_text(student_5.name)
    expect(page).to have_text(student_1.name)

    fill_in 'Filter Resources', with: 'level'
    click_button "Pick Level: #{level_2.filter_display_name}"

    expect(page).not_to have_text("Level: #{level_1.filter_display_name}")

    expect(page).to have_text(student_3.name)
    expect(page).not_to have_text(student_1.name)

    # Search for a student in the filtered level
    student_name = student_3.name
    fill_in 'Filter Resources', with: student_name
    click_button "Pick Search by Name: #{student_name}"

    expect(page).to have_text(student_name)
    expect(page).to_not have_text(student_2.name)

    # Clear the filter
    find("button[title='Remove selection: #{student_name}']").click

    expect(page).to have_text(student_2.name)
    expect(page).to have_text(student_3.name)

    # Switch to level which will have pagination
    fill_in 'Filter Resources', with: 'level'
    click_button "Pick Level: #{level_3.filter_display_name}"

    expect(page).to_not have_text(student_2.name)

    click_button('Load More...')

    expect(page).to have_text(student_6.name)

    # Clear the level filter
    find("button[title='Remove selection: #{level_3.filter_display_name}']")
      .click

    expect(page).to have_text(student_2.name)

    click_button('Load More...')

    expect(page).to have_text(student_1.name)
    expect(page).to have_text(student_5.name)
    expect(page).to have_text(student_6.name)

    # Filter by level using student distribution
    find("div[aria-label='Students in level 1']").click

    expect(page).to_not have_text('Elderberry')
    expect(page).to have_text('Zucchini')
  end

  context 'when there are more than one team coaches' do
    let(:another_student_coach) { create :faculty, school: school }

    before do
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: another_student_coach,
             student: student_2
    end

    scenario "one team coach can use the filter to see another coach's students" do
      sign_in_user student_coach.user, referrer: students_course_path(course)

      fill_in 'Filter Resources', with: student_coach.name
      click_button "Pick Personal Coach: #{student_coach.name}"

      expect(page).to have_text(student_6.name)
      expect(page).to_not have_text(student_2.name)

      fill_in 'Filter Resources', with: another_student_coach.name
      click_button "Pick Personal Coach: #{another_student_coach.name}"

      expect(page).not_to have_text(student_6.name)
      expect(page).to have_text(student_2.name)
    end
  end

  scenario 'course coach checks list of directly assigned coaches' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    click_button('Load More...')

    expected_initials =
      student_coach.name.split(' ')[0..1]
        .map { |name_fragment| name_fragment[0] }
        .map(&:capitalize)
        .join

    within("a[data-student-id='#{student_6.id}']") do
      find('.tooltip__trigger', text: expected_initials).hover
    end

    expect(page).to have_text(student_coach.name)
  end

  context 'when there are more than 4 coaches directly assigned to a team' do
    let(:student_coach_2) { create :faculty, school: school }
    let(:student_coach_3) { create :faculty, school: school }
    let(:student_coach_4) { create :faculty, school: school }
    let(:student_coach_5) { create :faculty, school: school }

    before do
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: student_coach_2,
             student: student_6
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: student_coach_3,
             student: student_6
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: student_coach_4,
             student: student_6
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: student_coach_5,
             student: student_6
    end

    scenario 'course coach checks names of coaches hidden from main list' do
      possible_names = [
        student_coach.name,
        student_coach_2.name,
        student_coach_3.name,
        student_coach_4.name,
        student_coach_5.name
      ]

      sign_in_user course_coach.user, referrer: students_course_path(course)

      click_button('Load More...')

      within("a[data-student-id='#{student_6.id}']") do
        find('.tooltip__trigger', text: '+2').hover
      end

      find('.tooltip__bubble')
        .text
        .strip
        .split("\n")
        .each { |name| expect(name).to be_in(possible_names) }
    end
  end

  context 'when all students have completed a level' do
    # Create new levels with no students
    let!(:level_4) { create :level, :four, course: course }
    let!(:level_5) { create :level, :five, course: course }

    before { level_1.students.each { |s| s.update!(level_id: level_2.id) } }

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
    let!(:locked_level_4) do
      create :level, :four, course: course, unlock_at: 5.days.from_now
    end
    let!(:locked_level_5) do
      create :level, :five, course: course, unlock_at: 5.days.from_now
    end

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

    fill_in 'Filter Resources', with: student_coach.name
    click_button "Pick Personal Coach: #{student_coach.name}"

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

  scenario 'coach filters students by tags applied to their team' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    click_button 'Order by Last Created'
    click_button 'Order by Name'

    student_in_first_page =
      course
        .students
        .where.not(id: student_2.id)
        .joins(:user)
        .order('users.name')
        .first

    expect(page).to have_text(student_in_first_page.name)

    within("div[aria-label='Students in level 1']") do
      expect(page).to have_text('1')
    end

    within("div[aria-label='Students in level 2']") do
      expect(page).to have_text('2')
    end

    within("div[aria-label='Students in level 3']") do
      expect(page).to have_text('3')
    end

    fill_in 'Filter Resources', with: 'vegetable'
    click_button 'Pick Student Tags: vegetable'

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
    expect(page).not_to have_text(student_in_first_page.name)
    expect(page).to have_text('Asparagus')
    expect(page).to have_text('Zucchini')

    fill_in 'Filter Resources', with: 'z'
    click_button 'Pick Student Tags: starts with z'

    within("div[aria-label='Students in level 2']") do
      expect(page).to have_text('0')
    end

    within("div[aria-label='Students in level 1']") do
      expect(page).to have_text('1')
    end

    expect(page).not_to have_text('Asparagus')
    expect(page).not_to have_text(student_in_first_page.name)
    expect(page).to have_text('Zucchini')
  end

  scenario 'coach searches student by email' do
    sign_in_user course_coach.user, referrer: students_course_path(course)

    click_button 'Order by Last Created'
    click_button 'Order by Name'

    students_sorted_by_name = course.students.joins(:user).order('users.name')
    student_to_search = students_sorted_by_name[5]
    another_student = students_sorted_by_name.first

    expect(page).to have_text(another_student.name)

    # Apply search by email filter
    student_email = student_to_search.email
    fill_in 'Filter Resources', with: student_email
    click_button "Pick Search by Email: #{student_email}"

    expect(page).not_to have_text(another_student.name)
    expect(page).to have_text(student_to_search.name)

    # Clear the filter
    find("button[title='Remove selection: #{student_email}']").click
    expect(page).to have_text(another_student.name)
  end
end
