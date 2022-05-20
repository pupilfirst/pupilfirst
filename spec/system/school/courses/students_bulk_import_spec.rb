require 'rails_helper'

feature 'Course students bulk importer', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course
  let(:school) { create :school, :current }
  let!(:domain) { create :domain, :primary, school: school }
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }

  let!(:level_1) { create :level, :one, course: course }

  def attach_csv_file(file_name)
    attach_file 'csv',
                File.absolute_path(
                  Rails.root.join("spec/support/uploads/students/#{file_name}")
                ),
                visible: false
  end

  scenario 'school admin attaches a valid csv file for import' do
    sign_in_user school_admin.user,
                 referrer: school_course_students_path(course)

    click_button 'Bulk Import'

    expect(page).to have_text 'Download an example .csv file'

    attach_csv_file('student_import_valid_data.csv')

    expect(page).to have_text 'Super Man'
    expect(page).to have_text 'bat@man.com'
    expect(page).to have_text 'tag1'

    click_button 'Import Students'

    expect(page).to have_text('Import initiated successfully!')

    expect(course.reload.founders.count).to eq(2)

    student_1 = User.find_by(email: 'super@man.com').founders.first
    student_2 = User.find_by(email: 'bat@man.com').founders.first

    expect(student_1.name).to eq('Super Man')
    expect(student_2.name).to eq('Bat Man')

    expect(student_1.title).to eq('Awesome')
    expect(student_2.title).to eq('Head')

    expect(student_1.startup.tag_list).to match_array(%w[tag1 tag2])
    expect(student_2.startup.tag_list).to match_array(%w[tag1])

    # Check admin notification
    open_email(school_admin.email)

    email_subject = current_email.subject
    email_body = current_email.body

    expect(email_subject).to eq('Import of Students Completed')

    expect(email_body).to have_content(
      "Your request to import students in #{course.name} course, was successfully completed."
    )
    expect(email_body).to have_content('Students requested: 2')
    expect(email_body).to have_content('Students added: 2')
    expect(page).to_not have_content(
                          'Some of the students you tried to import already exist in the course'
                        )

    # Check student notification
    open_email('super@man.com')

    expect(current_email.subject).to have_content(
      "You have been added as a student in #{school.name}"
    )
  end

  scenario 'admin onboards students with notification unchecked' do
    sign_in_user school_admin.user,
                 referrer: school_course_students_path(course)

    click_button 'Bulk Import'
    expect(page).to have_text 'Download an example .csv file'

    attach_csv_file('student_import_valid_data.csv')
    expect(page).to have_text 'Super Man'

    # uncheck notification option
    page.find(
      'label',
      text: 'Notify students, and send them a link to sign into this school.'
    ).click

    click_button 'Import Students'

    expect(page).to have_text('Import initiated successfully!')
    expect(course.reload.founders.count).to eq(2)

    # Check student notification
    open_email('super@man.com')

    expect(current_email).to eq(nil)
  end

  scenario 'admin uploads a csv with invalid template for import' do
    sign_in_user school_admin.user,
                 referrer: school_course_students_path(course)

    click_button 'Bulk Import'

    attach_csv_file('student_import_wrong_template.csv')

    expect(page).to have_text(
      'The selected CSV file does not have a valid template'
    )
  end

  scenario 'admin uploads a csv with invalid data' do
    sign_in_user school_admin.user,
                 referrer: school_course_students_path(course)

    click_button 'Bulk Import'

    attach_csv_file('student_import_invalid_data.csv')

    expect(page).to have_text(
      'The CSV file has invalid data in few cells. Please fix the errors listed below and try again.'
    )

    # Only erroneous rows are displayed
    expect(page).to_not have_text('Bat Man')
    expect(page).to have_text('Super Man')
    expect(page).to have_text('tag6')

    expect(page).to have_text('Here is a summary of the errors in the sheet:')
    expect(page).to have_text(
      "Name column can't be blank and should be within 250 characters"
    )
    expect(page).to have_text("Email has to be valid and can't be blank")
  end

  context 'import list has a student that already exists' do
    let!(:user) do
      create :user, email: 'bat@man.com', school: school, title: 'New Title'
    end
    let!(:startup) { create :team, level: level_1 }
    let!(:founder) { create :founder, startup: startup, user: user }

    scenario 'admin uploads csv with email of existing student' do
      sign_in_user school_admin.user,
                   referrer: school_course_students_path(course)

      click_button 'Bulk Import'

      attach_csv_file('student_import_valid_data.csv')

      click_button 'Import Students'

      expect(page).to have_text('Import initiated successfully!')

      expect(course.reload.founders.count).to eq(2)

      student = User.find_by(email: 'bat@man.com').founders.first
      expect(student.title).to eq('New Title')

      # Admin is informed in the email about duplication
      open_email(school_admin.email)

      email_body = current_email.body

      expect(email_body).to have_content(
        'Some of the students you tried to import were already enrolled in the course'
      )

      expect(current_email.attachments.first.body.encoded).to have_text(
        'bat@man.com'
      )
    end
  end
end
