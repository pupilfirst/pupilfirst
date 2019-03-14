require 'rails_helper'

feature 'Founders Index' do
  include UserSpecHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }

  let!(:school_admin) { create :school_admin, school: school }

  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }

  let!(:startup_1) { create :startup, level: level_1 }
  let!(:startup_2) { create :startup, level: level_2 }

  let!(:name_1) { (Faker::Lorem.words(2).join ' ').titleize }
  let!(:email_1) { Faker::Internet.email }

  let!(:name_2) { (Faker::Lorem.words(3).join ' ').titleize }
  let!(:email_2) { Faker::Internet.email }

  let!(:new_product_name) { (Faker::Lorem.words(4).join ' ').titleize }

  before do
    # Create a domain for school
    create :domain, :primary, school: school
  end

  scenario 'school admin visits a course index', js: true do
    sign_in_user school_admin.user, referer: school_course_students_path(course)

    # list all students
    expect(page).to have_text("All levels")
    expect(page).to have_text(startup_1.founders.first.name)
    expect(page).to have_text(startup_2.founders.last.name)

    # Add few students
    click_button 'Add New Students'

    fill_in 'Name', with: name_1
    fill_in 'Email', with: email_1
    click_button 'Add to List'

    fill_in 'Name', with: name_2
    fill_in 'Email', with: email_2
    click_button 'Add to List'

    expect(page).to have_text(name_1.to_s)
    expect(page).to have_text("(#{email_1})")
    expect(page).to have_text(name_2.to_s)
    expect(page).to have_text("(#{email_2})")

    click_button 'Save List'

    expect(page).to have_text("Student(s) created successfully")
    expect(page).to have_text(name_1)
    expect(page).to have_text(name_2)
    founder_1 = User.find_by(email: email_1).founders.first
    founder_2 = User.find_by(email: email_2).founders.first
    expect(founder_1.name).to eq(name_1)
    expect(founder_2.name).to eq(name_2)

    click_button 'Add New Students'
    fill_in 'Name', with: name_1
    fill_in 'Email', with: email_1
    click_button 'Add to List'
    click_button 'Save List'
    expect(page).to have_text("Student(s) with given email(s) already exist in this course!")
    click_button 'close'

    find("a", text: name_1).click
    expect(page).to have_text(founder_1.name)
    expect(page).to have_text(founder_1.startup.product_name)
    fill_in 'Team Name', with: new_product_name, fill_options: { clear: :backspace }
    click_button 'Update Student'
    expect(page).to have_text("Student updated successfully")
    founder_1.reload
    expect(founder_1.startup.product_name).to eq(new_product_name)
  end
end
