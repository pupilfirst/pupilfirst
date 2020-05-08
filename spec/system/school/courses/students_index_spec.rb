require 'rails_helper'

feature 'School students index', js: true do
  include UserSpecHelper
  include NotificationHelper

  let(:tag_1) { "Single Student" }
  let(:tag_2) { "Another Tag" }
  let(:tags) { [tag_1, tag_2] }

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current, founder_tag_list: tags }
  let!(:course) { create :course, school: school }

  let!(:school_admin) { create :school_admin, school: school }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }

  context 'with some students' do
    let!(:startup_1) { create :startup, level: level_1 }
    let!(:startup_2) { create :startup, level: level_2 }
    let(:team_in_different_course) { create :team }

    let(:team_with_lone_student) { create :team, level: level_2 }
    let!(:lone_student) { create :founder, startup: team_with_lone_student, tag_list: tags }

    let(:name_1) { Faker::Name.name }
    let(:email_1) { Faker::Internet.email(name: name_1) }
    let(:title_1) { Faker::Lorem.words(number: 2).join(" ") }
    let(:affiliation_1) { Faker::Lorem.words(number: 2).join(" ") }

    let(:name_2) { Faker::Name.name }
    let(:email_2) { Faker::Internet.email(name: name_2) }

    let!(:new_team_name) { (Faker::Lorem.words(number: 4).join ' ').titleize }

    let!(:course_coach) { create :faculty, school: school }
    let!(:coach_in_different_course) { create :faculty, school: school }

    before do
      create :faculty_course_enrollment, faculty: course_coach, course: course
      create :faculty_course_enrollment, faculty: coach_in_different_course, course: team_in_different_course.course
    end

    scenario 'School admin adds new students and a team' do
      sign_in_user school_admin.user, referer: school_course_students_path(course)

      expect(page).to have_text(startup_1.founders.first.name)
      expect(page).to have_text(startup_2.founders.last.name)

      # Add few students
      click_button 'Add New Students'

      # Student, alone in a team.
      fill_in 'Name', with: name_1
      fill_in 'Email', with: email_1
      fill_in 'Title', with: title_1
      fill_in 'Affiliation', with: affiliation_1
      fill_in 'Tags', with: 'Abc'
      find('span[title="Add new tag Abc"]').click
      fill_in 'Tags', with: 'Def'
      find('span[title="Add new tag Def"]').click
      click_button 'Add to List'

      # Student, alone, but with a team name.
      fill_in 'Name', with: name_2
      fill_in 'Email', with: email_2
      fill_in 'Team Name', with: 'some team name'

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
      expect(page).to have_text('Add more team members!')

      # An actual team with two students.
      name_3 = Faker::Name.name
      email_3 = Faker::Internet.email(name: name_3)
      name_4 = Faker::Name.name
      email_4 = Faker::Internet.email(name: name_4)

      fill_in 'Name', with: name_3
      fill_in 'Email', with: email_3
      fill_in 'Team Name', with: new_team_name

      click_button 'Add to List'

      fill_in 'Name', with: name_4
      fill_in 'Email', with: email_4
      fill_in 'Team Name', with: new_team_name

      click_button 'Add to List'

      click_button 'Save List'

      expect(page).to have_text("All students were created successfully")
      dismiss_notification

      expect(page).to have_text(name_1)
      expect(page).to have_text(name_2)

      student_1_user = User.find_by(email: email_1)
      student_1 = student_1_user.founders.first
      student_2_user = User.find_by(email: email_2)
      student_2 = student_2_user.founders.first
      student_3_user = User.find_by(email: email_3)
      student_3 = student_3_user.founders.first
      student_4_user = User.find_by(email: email_4)
      student_4 = student_4_user.founders.first

      expect(student_1_user.name).to eq(name_1)
      expect(student_2_user.name).to eq(name_2)
      expect(student_3_user.name).to eq(name_3)
      expect(student_4_user.name).to eq(name_4)

      expect(student_1_user.title).to eq(title_1)
      expect(student_2_user.title).to eq('Student') # the default should have been set.
      expect(student_3_user.title).to eq('Student')
      expect(student_4_user.title).to eq('Student')

      expect(student_1_user.affiliation).to eq(affiliation_1)
      expect(student_2_user.affiliation).to eq(nil)
      expect(student_3_user.affiliation).to eq(nil)
      expect(student_4_user.affiliation).to eq(nil)

      expect(student_1.startup.name).to eq(name_1)
      expect(student_2.startup.name).to eq(name_2)
      expect(student_3.startup.name).to eq(new_team_name)
      expect(student_4.startup.name).to eq(new_team_name)
      expect(student_3.startup.id).to eq(student_4.startup.id)

      expect(student_1.tag_list).to contain_exactly('Abc', 'Def')
      expect(student_2.tag_list).to contain_exactly('Abc', 'Def', 'GHI JKL')
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
          fill_in 'Email', with: Faker::Internet.email(name: name_3)
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

        # Coach in a different course must not be listed.
        expect(page).to have_text('Team Coaches')
        expect(page).not_to have_text(coach_in_different_course.name)

        # But it should be possible to assign a coach in 'this' course.
        find("div[title='Select #{course_coach.name}']").click

        click_button 'Update Student'

        expect(page).to have_text("Student updated successfully")

        dismiss_notification

        expect(founder.reload.startup.faculty.find_by(id: course_coach)).to be_present
      end
    end

    context 'school admin marks team as inactive' do
      let!(:inactive_team_1) { create :startup, level: level_1 }
      let(:access_ends_at) { 1.day.from_now }

      scenario 'School admin updates access end date' do
        sign_in_user school_admin.user, referer: school_course_students_path(course)

        expect(page).to have_link("Inactive Students", href: school_course_inactive_students_path(course))

        founder = inactive_team_1.founders.first
        expect(page).to have_text(founder.name)

        find("a", text: founder.name).click

        expect(page).to have_text(founder.startup.name)
        fill_in "Team's Access Ends On", with: access_ends_at.to_date.iso8601
        click_button 'Update Student'

        expect(page).to have_text("Student updated successfully")
        dismiss_notification

        expect(
          founder.reload.startup.access_ends_at.in_time_zone(founder.user.time_zone).to_date
        ).to eq(access_ends_at.to_date)

        find("a", text: founder.name).click
        fill_in "Team's Access Ends On", with: 1.day.ago.iso8601
        click_button 'Update Student'

        expect(page).to have_text("Team has been updated, and moved to list of inactive students")
        dismiss_notification

        expect(founder.reload.startup.access_ends_at.to_date).to eq(1.day.ago.to_date)
        expect(page).not_to have_text(founder.name)
      end
    end

    scenario 'school admin marks students as dropped out' do
      # Enroll the coach as a team coach in all three teams.
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: course_coach, startup: startup_1
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: course_coach, startup: startup_2
      create :faculty_startup_enrollment, :with_course_enrollment, faculty: course_coach, startup: team_with_lone_student

      sign_in_user school_admin.user, referer: school_course_students_path(course)

      # Mark a student in a team of more than one students as dropped out.
      founder = startup_2.founders.last
      founder_user = founder.user

      find("a", text: founder_user.name).click

      expect(page).to have_text(founder_user.name)
      expect(page).to have_text(founder.startup.name)
      expect(course_coach.startups.count).to eq(3)

      click_button 'Actions'
      click_button 'Dropout Student'

      dismiss_notification

      expect(page).not_to have_text(founder_user.name)

      # The student's team name should now be the student's own name.
      expect(founder.reload.startup.name).to eq(founder_user.name)

      # The team should have been marked as exited.
      expect(founder.startup.dropped_out_at).not_to eq(nil)

      # The student should be in a team without any directly linked coaches.
      expect(founder.startup.faculty.count).to eq(0)

      # However the coach should still be linked to the same number of teams.
      expect(course_coach.startups.count).to eq(3)

      # Mark a student who is alone in a team as dropped out.
      expect(team_with_lone_student.faculty.count).to eq(1)

      find("a", text: lone_student.name).click

      click_button 'Actions'
      click_button 'Dropout Student'

      expect(page).not_to have_text(founder_user.name)

      lone_user_team = lone_student.reload.startup
      expect(lone_user_team.dropped_out_at).not_to eq(nil)
      # The student's team should not have changed.
      expect(lone_user_team).to eq(team_with_lone_student)

      # All coaches should have been removed from the team.
      expect(lone_user_team.faculty.count).to eq(0)
      expect(course_coach.startups.count).to eq(2)
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

    scenario 'school admin tries to filter students' do
      sign_in_user school_admin.user, referer: school_course_students_path(course)

      # filter by level
      fill_in "search", with: "level"
      click_button level_2.name
      expect(page).to have_text(startup_2.name)
      expect(page).not_to have_text(startup_1.name)
      click_button "Remove selection: #{level_2.name}"

      # filter by tag
      fill_in "search", with: tag_1
      click_button "Pick Tag: Single Student"
      expect(page).to have_text(lone_student.name)
      expect(page).to have_text(tag_2)
      expect(page).not_to have_text(startup_1.name)
      expect(page).not_to have_text(startup_2.name)
      click_button "Remove selection: Single Student"

      # filter by name
      name = startup_1.founders.first.name
      fill_in "search", with: name
      click_button name
      expect(page).to have_text(startup_1.name)
      click_button "Remove selection: #{name}"

      # filter by team name
      team_name = startup_2.name
      fill_in "search", with: team_name
      click_button team_name
      expect(page).to have_text(startup_2.founders.first.name)
      expect(page).not_to have_text(lone_student.name)
      click_button "Remove selection: #{team_name}"

      # filter by email
      email = startup_1.founders.first.email
      fill_in "search", with: email
      click_button email
      expect(page).to have_text(startup_1.name)
      expect(page).not_to have_text(startup_2.name)
      expect(page).not_to have_text(lone_student.name)
      click_button "Remove selection: #{email}"
    end
  end

  context 'when there are a large number of teams' do
    let!(:teams) { create_list :startup, 30, level: level_1 }

    def safe_random_team
      @selected_team_ids ||= []
      team = Startup.all.where.not(id: @selected_team_ids).order('random()').first
      @selected_team_ids << team.id
      team
    end

    let(:oldest_created) { safe_random_team }
    let(:newest_created) { safe_random_team }
    let(:oldest_updated) { safe_random_team }
    let(:newest_updated) { safe_random_team }
    let(:team_aaa) { safe_random_team }
    let(:team_zzz) { safe_random_team }

    before do
      team_aaa.update!(name: 'A aa')
      team_zzz.update!(name: 'Z zz')
      oldest_created.update!(created_at: Time.at(0))
      newest_created.update!(created_at: 1.day.from_now)
      oldest_updated.update!(updated_at: Time.at(0))
      newest_updated.update!(updated_at: 1.day.from_now)
    end

    scenario 'school admin can order students' do
      sign_in_user school_admin.user, referer: school_course_students_path(course)

      click_button "Order by Name"
      click_button "Order by Last Created"

      expect(find(".student-team-container:first-child")).to have_text(newest_created.name)

      click_button('Load More')

      expect(find(".student-team-container:last-child")).to have_text(oldest_created.name)

      click_button "Order by Last Created"
      click_button "Order by Last Updated"

      expect(find(".student-team-container:first-child")).to have_text(newest_updated.name)

      click_button('Load More')

      expect(find(".student-team-container:last-child")).to have_text(oldest_updated.name)

      click_button "Order by Last Updated"
      click_button "Order by Name"

      expect(find(".student-team-container:first-child")).to have_text(team_aaa.name)

      click_button('Load More')

      expect(find(".student-team-container:last-child")).to have_text(team_zzz.name)
    end
  end
end
