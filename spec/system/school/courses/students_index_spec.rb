require 'rails_helper'

feature 'School students index', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }

  let!(:school_admin) { create :school_admin, school: school }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }

  let!(:startup_1) { create :startup, level: level_1 }
  let!(:startup_2) { create :startup, level: level_2 }

  let(:name_1) { Faker::Name.name }
  let(:email_1) { Faker::Internet.email(name_1) }

  let(:name_2) { Faker::Name.name }
  let(:email_2) { Faker::Internet.email(name_2) }

  let!(:new_team_name) { (Faker::Lorem.words(4).join ' ').titleize }

  let!(:inactive_team_1) { create :startup, level: level_1, access_ends_at: 1.day.ago }

  let!(:course_coach) { create :faculty, school: school }
  let!(:coach) { create :faculty, school: school }
  let!(:exited_coach) { create :faculty, school: school, exited: true }

  before do
    # Create a domain for school
    create :domain, :primary, school: school
    FacultyCourseEnrollment.create(faculty: course_coach, course: course)
  end

  scenario 'school admin visits a course index' do
    sign_in_user school_admin.user, referer: school_course_students_path(course)

    # list all students
    expect(page).to have_text("All levels")
    expect(page).to have_text(startup_1.founders.first.name)
    expect(page).to have_text(startup_2.founders.last.name)

    # Add few students
    click_button 'Add New Students'

    fill_in 'Name', with: name_1
    fill_in 'Email', with: email_1
    fill_in 'Tags', with: 'Abc'
    find('span[title="Add new tag Abc"]').click
    fill_in 'Tags', with: 'Def'
    find('span[title="Add new tag Def"]').click
    click_button 'Add to List'

    fill_in 'Name', with: name_2
    fill_in 'Email', with: email_2

    # Remove both tags, then add one back - the unpersisted tag should be suggested.
    find('span[title="Remove tag Abc"]').click
    find('span[title="Remove tag Def"]').click
    fill_in 'Tags', with: 'ab' # Lowercase search should still list capitalized result.
    find('span[title="Pick tag Abc"]').click
    fill_in 'Tags', with: 'DE' # Uppercase search should still list capitalized result.
    find('span[title="Pick tag Def"]').click
    fill_in 'Tags', with: 'GHI' # Uppercase search should still list capitalized result.
    find('span[title="Add new tag GHI"]').click

    click_button 'Add to List'

    expect(page).to have_text(name_1.to_s)
    expect(page).to have_text("(#{email_1})")
    expect(page).to have_text(name_2.to_s)
    expect(page).to have_text("(#{email_2})")

    click_button 'Save List'

    expect(page).to have_text("Student(s) created successfully")
    dismiss_notification

    expect(page).to have_text(name_1)
    expect(page).to have_text(name_2)

    founder_1 = User.find_by(email: email_1).founders.first
    founder_2 = User.find_by(email: email_2).founders.first

    expect(founder_1.name).to eq(name_1)
    expect(founder_2.name).to eq(name_2)
    expect(founder_1.tag_list).to contain_exactly('Abc', 'Def')
    expect(founder_2.tag_list).to contain_exactly('Abc', 'Def', 'GHI')

    name_3 = Faker::Name.name

    # Try adding an existing student and a new student at the same time.
    click_button 'Add New Students'

    expect do
      # First, an existing student.
      fill_in 'Name', with: name_1
      fill_in 'Email', with: email_1
      click_button 'Add to List'

      # Then a new student.
      fill_in 'Name', with: name_3
      fill_in 'Email', with: Faker::Internet.email(name_3)
      click_button 'Add to List'

      # Try to save both.
      click_button 'Save List'

      expect(page).to have_text("Student(s) created successfully")
      dismiss_notification
    end.to change { Founder.count }.by(1)

    expect(page).to have_text(name_3)

    # Update a student
    find("a", text: name_1).click
    expect(page).to have_text(founder_1.name)
    expect(page).to have_text(founder_1.startup.name)
    fill_in 'Name', with: founder_1.name + " Jr."
    fill_in 'Team Name', with: new_team_name, fill_options: { clear: :backspace }
    find('button[title="Exclude this student from the leaderboard"]').click
    click_button 'Update Student'

    expect(page).to have_text("Student updated successfully")
    dismiss_notification

    expect(founder_1.user_profile.reload.name).to end_with('Jr.')
    expect(founder_1.reload.startup.name).to eq(new_team_name)
    expect(founder_1.excluded_from_leaderboard).to eq(true)

    # Form a Team
    check "select-student-#{founder_1.id}"
    check "select-student-#{founder_2.id}"
    click_button 'Group as Team'
    expect(page).to have_text("Teams updated successfully")
    dismiss_notification
    founder_1.reload
    founder_2.reload
    expect(founder_1.startup.name).to eq(founder_2.startup.name)
    expect(page).to have_text(founder_1.startup.name)

    # Move out from a team
    check "select-student-#{founder_1.id}"
    click_button 'Move out from Team'
    expect(page).to have_text("Teams updated successfully")
    dismiss_notification
    founder_1.reload
    founder_2.reload
    expect(founder_1.startup.id).not_to eq(founder_2.startup.id)

    # Mark a student as exited
    founder = startup_2.founders.last
    find("a", text: founder.name).click
    expect(page).to have_text(founder.name)
    expect(page).to have_text(founder.startup.name)
    find('button[title="Prevent this student from accessing the course"]').click
    click_button 'Update Student'

    expect(page).to have_text("Student updated successfully")
    dismiss_notification
    founder.reload
    expect(founder.exited).to eq(true)

    # Assign a coach to a team
    founder = startup_2.founders.last
    find("a", text: founder.name).click
    expect(page).to have_text('Course Coaches')
    expect(page).to have_text('Exclusive Team Coaches')
    expect(page).to have_text(course_coach.name)
    within '.select-list__group' do
      expect(page).to_not have_text(exited_coach.name)
      find('.px-3', text: coach.name).click
    end
    click_button 'Update Student'
    expect(page).to have_text("Student updated successfully")
    dismiss_notification
    founder.reload
    expect(founder.startup.faculty.last).to eq(coach)

    # Inactive students list
    expect(page).to_not have_text(inactive_team_1.founders.first.name)
    click_link 'Inactive Students'
    expect(page).to have_text(inactive_team_1.founders.first.name)
    check "select-team-#{inactive_team_1.id}"
    expect(page).to have_button('Mark Team Active')
    click_button 'Mark Team Active'
    expect(page).to have_text("Teams marked active successfully!")
    visit school_course_students_path(course)
    expect(page).to have_text(inactive_team_1.founders.first.name)
  end
end
