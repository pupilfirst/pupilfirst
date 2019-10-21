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

  let(:team_with_lone_student) { create :team, level: level_2 }
  let!(:lone_student) { create :founder, startup: team_with_lone_student }

  let(:name_1) { Faker::Name.name }
  let(:email_1) { Faker::Internet.email(name_1) }
  let(:title_1) { Faker::Lorem.words(2).join(" ") }
  let(:affiliation_1) { Faker::Lorem.words(2).join(" ") }

  let(:name_2) { Faker::Name.name }
  let(:email_2) { Faker::Internet.email(name_2) }

  let!(:new_team_name) { (Faker::Lorem.words(4).join ' ').titleize }

  let!(:course_coach) { create :faculty, school: school }
  let!(:coach) { create :faculty, school: school }
  let!(:exited_coach) { create :faculty, school: school, exited: true }

  before do
    FacultyCourseEnrollment.create(faculty: course_coach, course: course)
  end

  scenario 'School admin adds new students' do
    sign_in_user school_admin.user, referer: school_course_students_path(course)

    # list all students
    expect(page).to have_text("All levels")
    expect(page).to have_text(startup_1.founders.first.name)
    expect(page).to have_text(startup_2.founders.last.name)

    # Add few students
    click_button 'Add New Students'

    fill_in 'Name', with: name_1
    fill_in 'Email', with: email_1
    fill_in 'Title', with: title_1
    fill_in 'Affiliation', with: affiliation_1
    fill_in 'Tags', with: 'Abc'
    find('span[title="Add new tag Abc"]').click
    fill_in 'Tags', with: 'Def'
    find('span[title="Add new tag Def"]').click
    click_button 'Add to List'

    fill_in 'Name', with: name_2
    fill_in 'Email', with: email_2

    # title and affiliation should have persisted values
    expect(page.find_field("title").value).to eq(title_1)
    expect(page.find_field("affiliation").value).to eq(affiliation_1)

    # Clear the title.
    fill_in 'Title', with: ''
    # Clear affiliation
    fill_in 'Affiliation', with: ''

    # Remove both tags, then add one back - the un-persisted tag should be suggested.
    find('span[title="Remove tag Abc"]').click
    find('span[title="Remove tag Def"]').click
    fill_in 'Tags', with: 'ab' # Lowercase search should still list capitalized result.
    find('span[title="Pick tag Abc"]').click
    fill_in 'Tags', with: 'DE' # Uppercase search should still list capitalized result.
    find('span[title="Pick tag Def"]').click

    # Uppercase search should still list capitalized result. Leading and trailing spaces should be removed, and extra
    # spaces should get 'squished'.
    fill_in 'Tags', with: '   GHI    JKL   '
    find('span[title="Add new tag GHI JKL"]').click

    click_button 'Add to List'

    expect(page).to have_text(name_1.to_s)
    expect(page).to have_text("(#{email_1})")
    expect(page).to have_text("#{title_1}, #{affiliation_1}")
    expect(page).to have_text(name_2.to_s)
    expect(page).to have_text("(#{email_2})")

    click_button 'Save List'

    expect(page).to have_text("All students were created successfully")
    dismiss_notification

    expect(page).to have_text(name_1)
    expect(page).to have_text(name_2)

    founder_1_user = User.find_by(email: email_1)
    founder_1 = founder_1_user.founders.first
    founder_2_user = User.find_by(email: email_2)
    founder_2 = founder_2_user.founders.first

    expect(founder_1_user.name).to eq(name_1)
    expect(founder_2_user.name).to eq(name_2)
    expect(founder_1_user.title).to eq(title_1)
    expect(founder_2_user.title).to eq('Student') # the default should have been set.
    expect(founder_1_user.affiliation).to eq(affiliation_1)
    expect(founder_2_user.affiliation).to eq(nil)
    expect(founder_1.tag_list).to contain_exactly('Abc', 'Def')
    expect(founder_2.tag_list).to contain_exactly('Abc', 'Def', 'GHI JKL')
  end

  context 'when adding a student who is already a user of another type' do
    let(:title) { Faker::Job.title }
    let(:affiliation) { Faker::Company.name }
    let(:coach_user) { create :user, title: title, affiliation: affiliation }
    let!(:original_name) { coach_user.name }
    let(:faculty) { create :faculty, user: coach_user }

    scenario 'School admin adds a coach as a student' do
      sign_in_user school_admin.user, referer: school_course_students_path(course)

      click_button 'Add New Students'

      expect do
        # First, an existing student.
        fill_in 'Name', with: Faker::Name.name
        fill_in 'Email', with: coach_user.email
        fill_in 'Title', with: Faker::Job.title
        fill_in 'Affiliation', with: Faker::Company.name
        click_button 'Add to List'
        click_button 'Save List'

        expect(page).to have_text("All students were created successfully")
        dismiss_notification
      end.to change { Founder.count }.by(1)

      expect(page).to have_text(coach_user.reload.name)

      # Name, title and affiliation of existing user should not be modified.
      expect(coach_user.name).to eq(original_name)
      expect(coach_user.title).to eq(title)
      expect(coach_user.affiliation).to eq(affiliation)
    end
  end

  context 'when there is one student in the course' do
    let(:existing_user) { create :user, email: email_1, name: name_1 }
    let!(:original_title) { existing_user.title }
    let!(:original_affiliation) { existing_user.affiliation }
    let(:name_3) { Faker::Name.name }

    before do
      create :student, user: existing_user, startup: startup_1
    end

    scenario 'School admin tries to add the existing student alongside a new student' do
      sign_in_user school_admin.user, referer: school_course_students_path(course)

      click_button 'Add New Students'

      expect do
        # First, an existing student.
        fill_in 'Name', with: name_1
        fill_in 'Email', with: email_1
        fill_in 'Title', with: Faker::Job.title
        fill_in 'Affiliation', with: Faker::Company.name
        click_button 'Add to List'

        # Then a new student.
        fill_in 'Name', with: name_3
        fill_in 'Email', with: Faker::Internet.email(name_3)
        click_button 'Add to List'

        # Try to save both.
        click_button 'Save List'

        expect(page).to have_text("1 of 2 students were added. Remaining students are already a part of the course")
        dismiss_notification
      end.to change { Founder.count }.by(1)

      expect(page).to have_text(name_3)

      # The title and affiliation of existing user should not be modified.
      expect(existing_user.reload.title).to eq(original_title)
      expect(existing_user.affiliation).to eq(original_affiliation)
    end
  end

  context 'when there are two existing students' do
    let(:user_1) { create :user, email: email_1, name: name_1, affiliation: Faker::Company.name }
    let(:user_2) { create :user, email: email_2, name: name_2, affiliation: Faker::Company.name }

    # Put two students by themselves in different teams.
    let(:team_1) { create :team, level: level_1 }
    let(:team_2) { create :team, level: level_1 }
    let!(:student_1) { create :student, user: user_1, startup: team_1 }
    let!(:student_2) { create :student, user: user_2, startup: team_2 }

    let(:new_title) { Faker::Job.title }

    scenario 'School admin edits student details' do
      sign_in_user school_admin.user, referer: school_course_students_path(course)

      # Update a student
      find("a", text: name_1).click

      expect(page).to have_text(user_1.name)
      expect(page.find_field("title").value).to eq(user_1.title)
      expect(page.find_field("affiliation").value).to eq(user_1.affiliation)

      fill_in 'Name', with: user_1.name + " Jr."
      expect(page).not_to have_field('Team Name')
      fill_in 'Title', with: new_title
      fill_in 'Affiliation', with: ''
      find('button[title="Exclude this student from the leaderboard"]').click
      click_button 'Update Student'

      expect(page).to have_text("Student updated successfully")
      dismiss_notification

      expect(user_1.reload.name).to end_with('Jr.')
      expect(user_1.title).to eq(new_title)
      expect(user_1.affiliation).to eq(nil)
      expect(student_1.reload.excluded_from_leaderboard).to eq(true)
      expect(student_1.startup.name).to eq(user_1.name)

      # Form a Team
      check "select-student-#{student_1.id}"
      check "select-student-#{student_2.id}"
      click_button 'Group as Team'
      expect(page).to have_text("Teams updated successfully")
      dismiss_notification

      expect(student_1.reload.startup).to eq(student_2.reload.startup)
      expect(page).to have_text(student_1.startup.name)

      # Try editing the team name for the newly formed team.
      find("a", text: user_1.name).click

      expect(page).to have_text(student_1.startup.name)

      fill_in 'Team Name', with: new_team_name
      click_button 'Update Student'

      expect(page).to have_text("Student updated successfully")
      dismiss_notification

      expect(student_1.reload.startup.name).to eq(new_team_name)

      # Move out from a team
      check "select-student-#{student_1.id}"
      click_button 'Move out from Team'
      expect(page).to have_text("Teams updated successfully")
      dismiss_notification
      student_1.reload
      student_2.reload
      expect(student_1.startup.id).not_to eq(student_2.startup.id)

      # Assign a coach to a team
      founder = startup_2.founders.last
      find("a", text: founder.user.name).click
      expect(page).to have_text('Team Coaches')

      within '.select-list__group' do
        expect(page).to_not have_text(exited_coach.name)
        find('.px-3', text: coach.name).click
      end

      click_button 'Update Student'
      expect(page).to have_text("Student updated successfully")
      dismiss_notification
      founder.reload
      expect(founder.startup.faculty.last).to eq(coach)
    end

    context 'when there is an inactive team' do
      let!(:inactive_team_1) { create :startup, level: level_1, access_ends_at: 1.day.ago }

      scenario 'School admin manipulates inactive teams' do
        sign_in_user school_admin.user, referer: school_course_students_path(course)

        # Student except inactive one should be listed.
        expect(page).to have_text(name_1)
        expect(page).to have_text(name_2)
        expect(page).not_to have_text(inactive_team_1.founders.first.name)

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
  end

  scenario 'school admin marks students as dropped out' do
    # Enroll the coach as a team coach in all three teams.
    create :faculty_startup_enrollment, faculty: coach, startup: startup_1
    create :faculty_startup_enrollment, faculty: coach, startup: startup_2
    create :faculty_startup_enrollment, faculty: coach, startup: team_with_lone_student

    sign_in_user school_admin.user, referer: school_course_students_path(course)

    # Mark a student in a team of more than one students as dropped out.
    founder = startup_2.founders.last
    founder_user = founder.user

    find("a", text: founder_user.name).click

    expect(page).to have_text(founder_user.name)
    expect(page).to have_text(founder.startup.name)
    expect(coach.startups.count).to eq(3)

    find('button[title="Prevent this student from accessing the course"]').click
    click_button 'Update Student'
    expect(page).to have_text("Student updated successfully")
    dismiss_notification

    # The student should have been marked as exited.
    expect(founder.reload.exited).to eq(true)

    # The student's team name should now be the student's own name.
    expect(founder.startup.name).to eq(founder_user.name)

    # The student should be in a team without any directly linked coaches.
    expect(founder.startup.faculty.count).to eq(0)

    # However the coach should still be linked to the same number of teams.
    expect(coach.startups.count).to eq(3)

    # Mark a student who is alone in a team as dropped out.
    expect(team_with_lone_student.faculty.count).to eq(1)

    find("a", text: lone_student.name).click

    find('button[title="Prevent this student from accessing the course"]').click
    click_button 'Update Student'
    expect(page).to have_text("Student updated successfully")
    dismiss_notification

    # The student's team should not have changed.
    lone_user_team = lone_student.reload.startup
    expect(lone_user_team).to eq(team_with_lone_student)

    # All coaches should have been removed from the team.
    expect(lone_user_team.faculty.count).to eq(0)
    expect(coach.startups.count).to eq(2)
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit school_course_students_path(course)
    expect(page).to have_text("Please sign in to continue.")
  end

  scenario 'school admin tries to add the same email twice' do
    sign_in_user school_admin.user, referer: school_course_students_path(course)

    # Add a student
    click_button 'Add New Students'

    fill_in 'Name', with: name_1
    fill_in 'Email', with: email_1
    fill_in 'Title', with: title_1
    fill_in 'Affiliation', with: affiliation_1
    fill_in 'Tags', with: 'Abc'
    find('span[title="Add new tag Abc"]').click
    fill_in 'Tags', with: 'Def'
    find('span[title="Add new tag Def"]').click
    click_button 'Add to List'

    # Try adding another student with same email

    fill_in 'Name', with: name_2
    fill_in 'Email', with: email_1

    expect(page).to have_text('email address not unique for student')
    expect(page).to have_button('Add to List', disabled: true)
  end
end
