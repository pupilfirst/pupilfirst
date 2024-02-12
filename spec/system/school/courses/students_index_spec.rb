require "rails_helper"

feature "School students index", js: true do
  include UserSpecHelper
  include NotificationHelper
  include HtmlSanitizerSpecHelper
  include MarkdownEditorHelper

  let(:tag_1) { "Single Student" }
  let(:tag_2) { "Another Tag" }
  let(:tags) { [tag_1, tag_2] }

  # Setup a course with a single student target, ...
  let(:school) { create :school, :current, student_tag_list: tags }
  let!(:domain) { create :domain, :primary, school: school }
  let!(:course) { create :course, school: school }
  let!(:live_cohort) { create :cohort, course: course }
  let!(:ended_cohort) { create :cohort, course: course, ends_at: 1.day.ago }

  let!(:school_admin) { create :school_admin, school: school }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  context "with some students" do
    let!(:student_1) { create :student, cohort: live_cohort, tag_list: [tag_1] }
    let!(:student_2) { create :student, cohort: live_cohort, tag_list: [tag_2] }
    let!(:student_access_ended) { create :student, cohort: ended_cohort }

    let(:name_1) { Faker::Name.name }
    let(:email_1) { Faker::Internet.email(name: name_1) }
    let(:title_1) { Faker::Lorem.words(number: 2).join(" ") }
    let(:affiliation_1) { Faker::Lorem.words(number: 2).join(" ") }

    let(:name_2) { Faker::Name.name }
    let(:email_2) { Faker::Internet.email(name: name_2) }

    let!(:new_team_name) { (Faker::Lorem.words(number: 4).join " ").titleize }

    let!(:course_coach) { create :faculty, school: school }
    let!(:coach_in_different_course) { create :faculty, school: school }

    before do
      create :faculty_cohort_enrollment,
             faculty: course_coach,
             cohort: live_cohort
    end

    scenario "School admin adds new students and a team" do
      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      expect(page).to have_text(student_1.name)
      expect(page).to have_text(student_2.name)

      # Add few students
      click_link "Add New Students"

      click_button "Pick a Cohort"
      click_button live_cohort.name

      # Student, alone in a team.
      fill_in "Name", with: name_1
      fill_in "Email", with: email_1
      fill_in "Title", with: title_1
      fill_in "Affiliation", with: affiliation_1
      fill_in "Tags", with: "Abc"
      find('button[title="Add new tag Abc"]').click
      fill_in "Tags", with: "Def"
      find('button[title="Add new tag Def"]').click
      click_button "Add to List"

      # Student, alone, but with a team name.
      fill_in "Name", with: name_2
      fill_in "Email", with: email_2
      fill_in "Team Name", with: "some team name"

      # title and affiliation should have persisted values
      expect(page.find_field("title").value).to eq(title_1)
      expect(page.find_field("affiliation").value).to eq(affiliation_1)

      # Clear the title.
      fill_in "Title", with: ""

      # Clear affiliation
      fill_in "Affiliation", with: ""

      # Remove both tags, then add one back - the un-persisted tag should be suggested.
      find('button[title="Remove tag Abc"]').click
      find('button[title="Remove tag Def"]').click
      fill_in "Tags", with: "ab" # Lowercase search should still list capitalized result.

      find('span[title="Pick tag Abc"]').click
      fill_in "Tags", with: "DE" # Uppercase search should still list capitalized result.
      find('span[title="Pick tag Def"]').click

      # Uppercase search should still list capitalized result. Leading and trailing spaces should be removed, and extra
      # spaces should get 'squished'.
      fill_in "Tags", with: "   GHI    JKL   "
      find('button[title="Add new tag GHI JKL"]').click

      click_button "Add to List"

      expect(page).to have_text(name_1.to_s)
      expect(page).to have_text("(#{email_1})")
      expect(page).to have_text("#{title_1}, #{affiliation_1}")
      expect(page).to have_text(name_2.to_s)
      expect(page).to have_text("(#{email_2})")
      expect(page).to have_text("Add more team members!")

      # An actual team with two students.
      name_3 = Faker::Name.name
      email_3 = Faker::Internet.email(name: name_3)
      name_4 = Faker::Name.name
      email_4 = Faker::Internet.email(name: name_4)

      fill_in "Name", with: name_3
      fill_in "Email", with: email_3
      fill_in "Team Name", with: new_team_name

      click_button "Add to List"

      fill_in "Name", with: name_4
      fill_in "Email", with: email_4
      fill_in "Team Name", with: new_team_name

      click_button "Add to List"

      click_button "Save List"

      expect(page).to have_text("All students were created successfully")
      dismiss_notification

      expect(page).to have_text(name_1)
      expect(page).to have_text(name_2)

      student_1_user = User.find_by(email: email_1)
      student_1 = student_1_user.students.first
      student_2_user = User.find_by(email: email_2)
      student_2 = student_2_user.students.first
      student_3_user = User.find_by(email: email_3)
      student_3 = student_3_user.students.first
      student_4_user = User.find_by(email: email_4)
      student_4 = student_4_user.students.first

      expect(student_1_user.name).to eq(name_1)
      expect(student_2_user.name).to eq(name_2)
      expect(student_3_user.name).to eq(name_3)
      expect(student_4_user.name).to eq(name_4)

      expect(student_1_user.title).to eq(title_1)
      expect(student_2_user.title).to eq("Student") # the default should have been set.
      expect(student_3_user.title).to eq("Student")
      expect(student_4_user.title).to eq("Student")

      expect(student_1_user.affiliation).to eq(affiliation_1)
      expect(student_2_user.affiliation).to eq(nil)
      expect(student_3_user.affiliation).to eq(nil)
      expect(student_4_user.affiliation).to eq(nil)

      expect(student_1.team).to eq(nil)
      expect(student_2.team).to eq(nil)
      expect(student_3.team.name).to eq(new_team_name)
      expect(student_4.team.name).to eq(new_team_name)
      expect(student_3.team.id).to eq(student_4.team.id)

      expect(student_1.cohort).to eq(live_cohort)
      expect(student_4.cohort).to eq(live_cohort)

      expect(student_1.tag_list).to contain_exactly("Abc", "Def")

      expect(student_2.tag_list).to contain_exactly("Abc", "Def", "GHI JKL")

      open_email(student_1_user.email)

      expect(current_email.subject).to include(
        "#{student_1_user.name}, you have been added as a student in #{school.name}"
      )

      expect(current_email.body).to have_link(
        "sign into #{school.name} and start working on this course"
      )

      open_email(student_2_user.email)

      expect(current_email.subject).to include(
        "#{student_2_user.name}, you have been added as a student in #{school.name}"
      )

      open_email(student_3_user.email)

      expect(current_email.subject).to include(
        "#{student_3_user.name}, you have been added as a student in #{school.name}"
      )

      expect(sanitize_html(current_email.body)).to include(
        "You have also been teamed up with #{student_4_user.name}"
      )

      open_email(student_4_user.email)

      expect(current_email.subject).to include(
        "#{student_4_user.name}, you have been added as a student in #{school.name}"
      )

      expect(sanitize_html(current_email.body)).to include(
        "You have also been teamed up with #{student_3_user.name}"
      )
    end

    scenario "school admin adds a student after disabling the notify option" do
      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      click_link "Add New Students"

      click_button "Pick a Cohort"
      click_button live_cohort.name

      fill_in "Name", with: name_1
      fill_in "Email", with: email_1
      click_button "Add to List"
      page.find(
        "label",
        text: "Notify students, and send them a link to sign into this school."
      ).click
      click_button "Save List"

      expect(page).to have_text("All students were created successfully")
      open_email(email_1)
      expect(current_email).to eq(nil)
    end

    context "when adding a student who is already a user of another type" do
      let(:title) { Faker::Job.title }
      let(:affiliation) { Faker::Company.name }
      let(:coach_user) { create :user, title: title, affiliation: affiliation }
      let!(:original_name) { coach_user.name }
      let(:faculty) { create :faculty, user: coach_user }

      scenario "School admin adds a coach as a student" do
        sign_in_user school_admin.user,
                     referrer: school_course_students_path(course)

        click_link "Add New Students"

        expect do
          # First, an existing student.
          click_button "Pick a Cohort"
          click_button live_cohort.name

          fill_in "Name", with: Faker::Name.name
          fill_in "Email", with: coach_user.email
          fill_in "Title", with: Faker::Job.title
          fill_in "Affiliation", with: Faker::Company.name
          click_button "Add to List"
          click_button "Save List"

          expect(page).to have_text("All students were created successfully")
          dismiss_notification
        end.to change { Student.count }.by(1)

        expect(page).to have_text(coach_user.reload.name)

        # Name, title and affiliation of existing user should not be modified.
        expect(coach_user.name).to eq(original_name)
        expect(coach_user.title).to eq(title)
        expect(coach_user.affiliation).to eq(affiliation)

        open_email(coach_user.email)

        expect(current_email.subject).to include(
          "#{coach_user.name}, you have been added as a student in #{school.name}"
        )

        expect(current_email.body).to have_link(
          "sign into #{school.name} and start working on this course"
        )
      end
    end

    context "when there is one student in the course" do
      let(:existing_user) { create :user, email: email_1, name: name_1 }
      let!(:original_title) { existing_user.title }
      let!(:original_affiliation) { existing_user.affiliation }
      let(:name_3) { Faker::Name.name }

      before { create :student, user: existing_user, cohort: live_cohort }

      scenario "School admin tries to add the existing student alongside a new student" do
        sign_in_user school_admin.user,
                     referrer: school_course_students_path(course)

        click_link "Add New Students"

        expect do
          # First, an existing student.
          click_button "Pick a Cohort"
          click_button live_cohort.name

          fill_in "Name", with: name_1
          fill_in "Email", with: email_1
          fill_in "Title", with: Faker::Job.title
          fill_in "Affiliation", with: Faker::Company.name
          click_button "Add to List"

          # Then a new student.
          fill_in "Name", with: name_3
          fill_in "Email", with: Faker::Internet.email(name: name_3)
          click_button "Add to List"

          # Try to save both.
          click_button "Save List"

          expect(page).to have_text(
            "1 of 2 students were added. Remaining students are already a part of the course"
          )
          dismiss_notification
        end.to change { Student.count }.by(1)

        expect(page).to have_text(name_3)

        # The title and affiliation of existing user should not be modified.
        expect(existing_user.reload.title).to eq(original_title)
        expect(existing_user.affiliation).to eq(original_affiliation)

        # The existing student should not have received any email.
        open_email(email_1)
        expect(current_email).to eq(nil)
      end
    end

    context "when there are two existing students" do
      let(:user_1) do
        create :user,
               email: email_1,
               name: name_1,
               affiliation: Faker::Company.name
      end
      let(:user_2) do
        create :user,
               email: email_2,
               name: name_2,
               affiliation: Faker::Company.name
      end

      let(:team) { create :team, cohort: live_cohort }

      let!(:student_1) do
        create :student, user: user_1, cohort: live_cohort, team: team
      end

      let!(:student_2) { create :student, user: user_2, cohort: live_cohort }

      let!(:student_3) { create :student, cohort: live_cohort, team: team }

      let(:new_title) { Faker::Job.title }

      scenario "School admin edits student details" do
        sign_in_user school_admin.user,
                     referrer: school_course_students_path(course)

        # Update a student
        within("div[data-student-name='#{name_1}']") { click_link "Edit" }

        expect(page).to have_text(user_1.name)
        expect(page.find_field("title").value).to eq(user_1.title)
        expect(page.find_field("affiliation").value).to eq(user_1.affiliation)

        fill_in "Name", with: user_1.name + " Jr."
        expect(page).not_to have_field("Team Name")
        fill_in "Title", with: new_title
        fill_in "Affiliation", with: ""
        click_button "Update Student"

        expect(page).to have_text("Student updated successfully")
        dismiss_notification

        expect(user_1.reload.name).to end_with("Jr.")
        expect(user_1.title).to eq(new_title)
        expect(user_1.affiliation).to eq(nil)

        # Assign a coach to a student

        within("div[data-student-name='#{student_2.user.name}']") do
          click_link "Edit"
        end

        # Coach in a different course must not be listed.
        expect(page).to have_text("Personal Coaches")
        expect(page).not_to have_text(coach_in_different_course.name)

        # But it should be possible to assign a coach in 'this' course.
        find("button[title='Select #{course_coach.name}']").click

        click_button "Update Student"

        expect(page).to have_text("Student updated successfully")

        dismiss_notification

        expect(student_2.reload.faculty.find_by(id: course_coach)).to be_present
      end

      scenario "School admin moves a student into another cohort" do
        sign_in_user school_admin.user,
                     referrer: school_course_students_path(course)

        # Update a student
        within("div[data-student-name='#{student_1.name}']") do
          click_link "Edit"
        end

        expect(page).to have_text(student_1.name)
        click_button live_cohort.name
        click_button ended_cohort.name
        click_button "Update Student"

        expect(page).to have_text("Student updated successfully")
        dismiss_notification

        expect(student_1.reload.cohort).to eq(ended_cohort)
        expect(student_1.team).to eq(nil)
      end
    end

    scenario "school admin marks students as dropped out" do
      # Enroll the coach as a personal coach for all students.
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: course_coach,
             student: student_1
      create :faculty_student_enrollment,
             :with_cohort_enrollment,
             faculty: course_coach,
             student: student_2

      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      # Mark a student in a team of more than one students as dropped out.

      within("div[data-student-name='#{student_1.user.name}']") do
        click_link "Edit"
      end

      expect(page).to have_text(student_1.user.name)
      expect(course_coach.students.count).to eq(2)

      click_link "Actions"
      click_button "Dropout Student"

      dismiss_notification

      expect(page).to have_text("Re-Activate Student")

      # The student should have been marked as exited.
      expect(student_1.reload.dropped_out_at).not_to eq(nil)

      # The student should have any directly linked coaches.
      expect(student_1.faculty.count).to eq(0)

      # The student should also be removed from coaches list.
      expect(course_coach.students.count).to eq(1)
    end

    scenario "school admin re-activates a dropped out student" do
      student_access_ended.update!(dropped_out_at: 1.day.ago)

      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      within("div[data-student-name='#{student_access_ended.user.name}']") do
        click_link "Edit"
      end

      click_link "Actions"
      click_button "Re-Activate Student"

      dismiss_notification

      expect(page).to have_text("Dropout Student")

      # The student should have been marked as exited.
      expect(student_access_ended.reload.dropped_out_at).to eq(nil)
    end

    scenario "user who is not logged in gets redirected to sign in page" do
      visit school_course_students_path(course)
      expect(page).to have_text("Please sign in to continue.")
    end

    scenario "school admin tries to add the same email twice" do
      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      # Add a student
      click_link "Add New Students"

      click_button "Pick a Cohort"
      click_button live_cohort.name

      fill_in "Name", with: name_1
      fill_in "Email", with: email_1
      fill_in "Title", with: title_1
      fill_in "Affiliation", with: affiliation_1
      fill_in "Tags", with: "Abc"
      find('button[title="Add new tag Abc"]').click
      fill_in "Tags", with: "Def"
      find('button[title="Add new tag Def"]').click
      click_button "Add to List"

      # Try adding another student with same email

      fill_in "Name", with: name_2
      fill_in "Email", with: email_1

      expect(page).to have_text("email address not unique for student")
      expect(page).to have_button("Add to List", disabled: true)
    end

    scenario "school admin tries to filter students" do
      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      # filter by tag
      fill_in "Filter Resources", with: tag_1
      click_button "Pick Student Tag: Single Student"
      expect(page).to have_text(student_1.name)
      expect(page).not_to have_text(student_2.name)
      click_button "Remove selection: Single Student"

      # filter by name
      name = student_1.name
      fill_in "Filter Resources", with: name

      click_button "Pick Search by Name: #{name}"

      expect(page).to have_text(student_1.name)
      click_button "Remove selection: #{name}"

      # filter by email
      email = student_1.email
      fill_in "Filter Resources", with: email
      click_button "Pick Search by Email: #{email}"

      expect(page).to have_text(student_1.name)
      expect(page).not_to have_text(student_2.name)
      click_button "Remove selection: #{email}"
    end
  end

  context "when there are a large number of teams" do
    let!(:students) { create_list :student, 30, cohort: live_cohort }

    def safe_random_students
      @selected_student_ids ||= []
      student =
        Student.where.not(id: @selected_student_ids).order("random()").first
      @selected_student_ids << student.id
      student
    end

    let(:oldest_created) { safe_random_students }
    let(:newest_created) { safe_random_students }
    let(:oldest_updated) { safe_random_students }
    let(:newest_updated) { safe_random_students }
    let(:student_aaa) { safe_random_students }
    let(:student_zzz) { safe_random_students }

    before do
      # Fix student names so that sort order isn't random.
      students.each_with_index do |s, i|
        s.user.update!(name: "Test Student #{i}")
      end

      student_aaa.user.update!(name: "Aa Aa")
      student_zzz.user.update!(name: "Zz Zz")
      oldest_created.update!(created_at: Time.at(0))
      newest_created.update!(created_at: 1.day.from_now)
      oldest_updated.update!(updated_at: Time.at(0))
      newest_updated.update!(updated_at: 1.day.from_now)
    end

    scenario "school admin can order students" do
      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      expect(page).to have_content("Showing 20 of 30 students")

      # Check ordering by last created
      expect(find(".student-container:first-child")).to have_text(
        newest_created.name
      )

      click_button("Load More")

      expect(find(".student-container:last-child")).to have_text(
        oldest_created.name
      )

      # Reverse sorting
      click_button "Order by Last Created"
      click_button "Order by First Created"

      expect(find(".student-container:first-child")).to have_text(
        oldest_created.name
      )

      click_button("Load More")

      expect(find(".student-container:last-child")).to have_text(
        newest_created.name
      )

      # Check ordering by last updated
      click_button "Order by First Created"
      click_button "Order by Last Updated"

      expect(find(".student-container:first-child")).to have_text(
        newest_updated.name
      )

      click_button("Load More")

      expect(find(".student-container:last-child")).to have_text(
        oldest_updated.name
      )

      # Reverse sorting
      click_button "Order by Last Updated"
      click_button "Order by First Updated"

      expect(find(".student-container:first-child")).to have_text(
        oldest_updated.name
      )

      click_button("Load More")

      expect(find(".student-container:last-child")).to have_text(
        newest_updated.name
      )

      # Check ordering by name
      click_button "Order by First Updated"
      click_button "Order by Name"

      expect(find(".student-container:first-child")).to have_text(
        student_aaa.name
      )

      click_button("Load More")

      expect(find(".student-container:last-child")).to have_text(
        student_zzz.name
      )
    end
  end

  context "when a course has no certificates" do
    let!(:student) { create :student, cohort: live_cohort }
    scenario "admin visits student editor to issue certificates" do
      sign_in_user school_admin.user,
                   referrer: "/school/students/#{student.id}/actions"

      expect(page).to have_text(
        "This course does not have any certificates to issue"
      )
    end
  end

  context "when a course has certificates" do
    let!(:student_without_certificate) { create :student, cohort: live_cohort }
    let(:student_with_certificate) { create :student, cohort: live_cohort }

    let!(:certificate_1) { create :certificate, course: course }
    let!(:certificate_2) { create :certificate, course: course }

    before do
      create :issued_certificate,
             user: student_with_certificate.user,
             issuer: school_admin.user,
             certificate: certificate_1,
             created_at: 1.day.ago
    end

    scenario "admin manually issues a certificate to a student" do
      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      within(
        "div[data-student-name='#{student_without_certificate.user.name}']"
      ) { click_link "Edit" }

      click_link "Actions"

      expect(page).to have_text(
        "This student has not been issued any certificates"
      )

      # Issue new certificate
      select certificate_2.name, from: "issue-certificate"

      click_button("Issue Certificate")

      expect(page).to have_text("Done!")
      dismiss_notification

      issued_certificate =
        student_without_certificate.user.issued_certificates.reload.last

      expect(issued_certificate.certificate).to eq(certificate_2)
      expect(issued_certificate.issuer).to eq(school_admin.user)

      within(
        "div[aria-label='Details of issued certificate #{issued_certificate.id}']"
      ) do
        expect(page).to have_link(issued_certificate.serial_number)
        expect(page).to have_text(school_admin.user.name)
        expect(page).to have_text(certificate_2.name)
        expect(page).to have_button("Revoke Certificate")
        expect(page).to have_text(
          issued_certificate.created_at.strftime("%B %-d, %Y")
        )
      end
    end

    scenario "admin revokes issued certificate and then issues another one" do
      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      within(
        "div[data-student-name='#{student_with_certificate.user.name}']"
      ) { click_link "Edit" }

      click_link "Actions"

      expect(page).to have_text(certificate_1.name)

      issued_certificate =
        student_with_certificate.user.issued_certificates.last

      # Revoke the issued certificate
      within(
        "div[aria-label='Details of issued certificate #{issued_certificate.id}']"
      ) { accept_confirm { click_button("Revoke Certificate") } }

      expect(page).to have_text("Done")

      dismiss_notification

      expect(issued_certificate.reload.revoked_at).to_not eq(nil)
      expect(issued_certificate.revoker).to eq(school_admin.user)

      within(
        "div[aria-label='Details of issued certificate #{issued_certificate.id}']"
      ) do
        expect(page).to have_text(school_admin.user.name, count: 2)
        expect(page).to have_text(
          issued_certificate.revoked_at.strftime("%B %-d, %Y")
        )
      end

      # Can issue new certificate
      select certificate_2.name, from: "issue-certificate"

      click_button("Issue Certificate")

      expect(page).to have_text("Done!")
      expect(
        student_with_certificate.user.reload.issued_certificates.count
      ).to eq(2)
    end
  end

  context "When standing is disabled for the school" do
    let!(:student) { create :student, cohort: live_cohort }

    scenario "school admin visits student standing" do
      sign_in_user school_admin.user,
                   referrer: "/school/students/#{student.id}/standing"

      expect(page).to have_text("School Standing is disabled")
    end
  end

  context "When standing is enabled for the school" do
    let!(:student) { create :student, cohort: live_cohort }
    let!(:standing_1) { create :standing, school: school, default: true }
    let!(:standing_2) { create :standing, school: school }
    let!(:standing_3) { create :standing, school: school }
    before { school.update!(configuration: { enable_standing: true }) }

    scenario "school admin visits student standing tab with no standing logs" do
      sign_in_user school_admin.user,
                   referrer: "/school/students/#{student.id}/standing"

      expect(page).to have_text("There are no entries in the log")

      expect(page).to have_text(standing_1.name)
    end

    scenario "school admin adds an entry to the student standing log" do
      sign_in_user school_admin.user,
                   referrer: "/school/students/#{student.id}/standing"

      expect(page).to have_text("There are no entries in the log")

      expect(page).to have_select(
        "current-standing",
        selected: standing_1.name,
        disabled: true
      )

      expect(page).to have_select(
        "change-standing",
        selected: "Select Standing"
      )

      select standing_2.name, from: "change-standing"

      expect(page).to have_text(standing_2.description)

      reason = Faker::Lorem.sentence

      add_markdown reason
      click_button "Add Entry"

      expect(page).to have_text("Standing log created successfully!")

      dismiss_notification

      expect(page).to have_text(standing_2.name)
      expect(page).to have_text(school_admin.user.name)
      expect(page).to have_text(reason)

      expect(page).to have_select(
        "current-standing",
        selected: standing_2.name,
        disabled: true
      )

      expect(page).to have_select(
        "change-standing",
        selected: "Select Standing"
      )

      open_email(student.user.email)

      expect(current_email.subject).to include(
        "Your standing in #{school.name} has been changed"
      )

      body = sanitize_html(current_email.body)

      expect(body).to have_text(
        "\n Your standing in test school has been changed from #{standing_1.name} to #{standing_2.name}."
      )

      expect(body).to have_text(reason)
    end

    context "when there are entries in the standing log" do
      let!(:user_standing) do
        create :user_standing, user: student.user, standing: standing_2
      end

      scenario "school admin deletes an entry in the log" do
        sign_in_user school_admin.user,
                     referrer: "/school/students/#{student.id}/standing"

        expect(page).to have_text(standing_2.name)
        expect(page).to have_text(user_standing.reason)

        expect(page).to have_select(
          "current-standing",
          selected: standing_2.name,
          disabled: true
        )

        expect(page).to have_select(
          "change-standing",
          selected: "Select Standing"
        )

        accept_confirm do
          find(
            "button[title='Delete Standing Log#{student.user.user_standings.last.id}']"
          ).click
        end

        expect(page).to have_text("Standing log deleted successfully")

        dismiss_notification

        expect(page).to have_text("There are no entries in the log")

        expect(page).to have_select(
          "current-standing",
          selected: standing_1.name,
          disabled: true
        )

        expect(page).to have_select(
          "change-standing",
          selected: "Select Standing"
        )
      end
    end
  end
end
