require 'rails_helper'

feature 'Courses Index', js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course_1) { create :course, school: school }
  let!(:course_2) { create :course, school: school }

  let!(:school_admin) { create :school_admin, school: school }

  let(:course_name) { Faker::Lorem.words(number: 2).join ' ' }
  let(:description) { Faker::Lorem.sentences.join ' ' }

  def file_path(filename)
    File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'files', filename))
  end

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  scenario 'School admin creates a course' do
    sign_in_user school_admin.user, referrer: school_courses_path

    # list all courses
    expect(page).to have_text("Add New Course")
    expect(page).to have_text(course_1.name)
    expect(page).to have_text(course_2.name)

    # Add a new course
    click_button 'Add New Course'

    fill_in 'Course name', with: course_name
    fill_in 'Course description', with: description

    within('div#public-signup') do
      click_button 'No'
    end

    click_button 'Create Course'

    expect(page).to have_text("Course created successfully")
    dismiss_notification

    expect(page).to have_text(course_name)

    course = Course.last

    expect(course.name).to eq(course_name)
    expect(course.description).to eq(description)
    expect(course.about).to eq(nil)
    expect(course.enable_leaderboard).to eq(false)
    expect(course.public_signup).to eq(false)
    expect(course.progression_behavior).to eq(Course::PROGRESSION_BEHAVIOR_LIMITED)
    expect(course.progression_limit).to eq(1)
  end

  context 'when a course exists' do
    let(:new_course_name) { Faker::Lorem.words(number: 2).join ' ' }
    let(:new_about) { Faker::Lorem.paragraph }
    let(:new_description) { Faker::Lorem.sentences.join ' ' }
    let(:course_end_date) { Time.zone.today }

    scenario 'School admin edits an existing course' do
      sign_in_user school_admin.user, referrer: school_courses_path

      find("a[title='Edit #{course_1.name}']").click

      fill_in 'Course name', with: new_course_name, fill_options: { clear: :backspace }
      fill_in 'Course description', with: new_description, fill_options: { clear: :backspace }
      fill_in 'Course end date', with: course_end_date.iso8601
      replace_markdown new_about
      select 'thrice', from: 'progression-limit'

      within('div#public-signup') do
        click_button 'Yes'
      end

      click_button 'Update Course'

      expect(page).to have_text("Course updated successfully")

      expect(course_1.reload.name).to eq(new_course_name)
      expect(course_1.description).to eq(new_description)
      expect(course_1.about).to eq(new_about)
      expect(course_1.public_signup).to eq(true)
      expect(course_1.ends_at.to_date).to eq(course_end_date)
      expect(course_1.progression_behavior).to eq(Course::PROGRESSION_BEHAVIOR_LIMITED)
      expect(course_1.progression_limit).to eq(3)
    end

    scenario 'School admin sets other progression behaviors on existing course' do
      sign_in_user school_admin.user, referrer: school_courses_path

      find("a[title='Edit #{course_1.name}']").click

      click_button 'Unlimited'
      click_button 'Update Course'

      expect(page).to have_text("Course updated successfully")
      expect(course_1.reload.progression_behavior).to eq(Course::PROGRESSION_BEHAVIOR_UNLIMITED)
      expect(course_1.progression_limit).to eq(nil)

      find("a[title='Edit #{course_1.name}']").click

      click_button 'Strict'
      click_button 'Update Course'

      expect(page).to have_text("Course updated successfully")

      expect(course_1.reload.progression_behavior).to eq(Course::PROGRESSION_BEHAVIOR_STRICT)
      expect(course_1.progression_limit).to eq(nil)
    end

    scenario 'School admin edits images associated with the course' do
      sign_in_user school_admin.user, referrer: school_courses_path

      find("a[title='Edit images for #{course_1.name}']").click

      expect(page).to have_text('Please choose an image file.', count: 2)

      attach_file 'course_thumbnail', file_path('logo_lipsum_on_light_bg.png'), visible: false
      attach_file 'course_cover', file_path('logo_lipsum_on_dark_bg.png'), visible: false

      click_button 'Update Images'

      expect(page).to have_text('Images have been updated successfully')

      find("a[title='Edit images for #{course_1.name}']").click

      expect(page).to have_text('Please pick a file to replace logo_lipsum_on_light_bg.png')
      expect(page).to have_text('Please pick a file to replace logo_lipsum_on_dark_bg.png')

      expect(course_1.cover).to be_attached
      expect(course_1.thumbnail).to be_attached
    end
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit school_courses_path
    expect(page).to have_text("Please sign in to continue.")
  end
end
