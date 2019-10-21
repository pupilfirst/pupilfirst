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

  let!(:new_course_name) { Faker::Lorem.words(2).join ' ' }
  let!(:new_course_name_1) { Faker::Lorem.words(2).join ' ' }
  let!(:new_description) { Faker::Lorem.sentences.join ' ' }
  let!(:new_about) { Faker::Lorem.paragraph }
  let!(:new_description_for_edit) { Faker::Lorem.sentences.join ' ' }
  let!(:grade_label_1) { Faker::Lorem.words(2).join ' ' }
  let!(:grade_label_2) { Faker::Lorem.words(2).join ' ' }
  let!(:grade_label_3) { Faker::Lorem.words(2).join ' ' }
  let!(:grade_label_4) { Faker::Lorem.words(2).join ' ' }
  let!(:grade_label_5) { Faker::Lorem.words(2).join ' ' }

  let(:date) { Date.today }

  scenario 'school admin visits courses and create a course' do
    sign_in_user school_admin.user, referer: school_courses_path

    # list all courses
    expect(page).to have_text("Add New Course")
    expect(page).to have_text(course_1.name)
    expect(page).to have_text(course_2.name)

    # Add a new course
    click_button 'Add New Course'

    fill_in 'Course Name', with: new_course_name
    fill_in 'Name', with: new_course_name
    fill_in 'Description', with: new_description
    within('div#leaderboard') do
      click_button 'Yes'
    end
    within('div#public-signup') do
      click_button 'No'
    end
    fill_in 'label1', with: grade_label_1
    find('label[for=label2]').click
    fill_in 'label2', with: grade_label_2
    find('label[for=label3]').click
    fill_in 'label3', with: grade_label_3
    find('label[for=label4]').click
    fill_in 'label4', with: grade_label_4
    find('label[for=label5]').click
    fill_in 'label5', with: grade_label_5
    click_button 'Create Course'

    expect(page).to have_text("Course created successfully")
    dismiss_notification

    expect(page).to have_text(new_course_name)
    course = Course.last
    expect(course.name).to eq(new_course_name)
    expect(course.description).to eq(new_description)
    expect(course.about).to eq(nil)
    expect(course.enable_leaderboard).to eq(true)
    expect(course.public_signup).to eq(false)
    expect(course.max_grade).to eq(5)
    expect(course.pass_grade).to eq(2)
    expect(course.grade_labels["1"]).to eq(grade_label_1)
    expect(course.grade_labels["2"]).to eq(grade_label_2)
    expect(course.grade_labels["3"]).to eq(grade_label_3)
    expect(course.grade_labels["4"]).to eq(grade_label_4)
    expect(course.grade_labels["5"]).to eq(grade_label_5)

    find("a", text: new_course_name).click
    fill_in 'Name', with: new_course_name_1, fill_options: { clear: :backspace }
    fill_in 'Description', with: new_description_for_edit, fill_options: { clear: :backspace }
    fill_in 'Course ends on', with: date.iso8601
    replace_markdown new_about
    within('div#leaderboard') do
      click_button 'No'
    end
    within('div#public-signup') do
      click_button 'Yes'
    end
    click_button 'Update Course'
    expect(page).to have_text("Course updated successfully")
    course.reload
    expect(course.name).to eq(new_course_name_1)
    expect(course.description).to eq(new_description_for_edit)
    expect(course.about).to eq(new_about)
    expect(course.enable_leaderboard).to eq(false)
    expect(course.public_signup).to eq(true)
    expect(course.ends_at.to_date).to eq(date)
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit school_courses_path
    expect(page).to have_text("Please sign in to continue.")
  end
end
