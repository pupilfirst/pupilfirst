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

  let!(:new_name) { (Faker::Lorem.words(4).join ' ').titleize }

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
    find('.ui-pnotify-container').click
    expect(page).to have_text(name_1)
    expect(page).to have_text(name_2)
    founder_1 = User.find_by(email: email_1).founders.first
    founder_2 = User.find_by(email: email_2).founders.first
    expect(founder_1.name).to eq(name_1)
    expect(founder_2.name).to eq(name_2)

    # try adding an existing student
    click_button 'Add New Students'
    fill_in 'Name', with: name_1
    fill_in 'Email', with: email_1
    click_button 'Add to List'
    click_button 'Save List'
    expect(page).to have_text("Student(s) with given email(s) already exist in this course!")
    find('.ui-pnotify-container').click
    click_button 'close'

    # Update a student
    find("a", text: name_1).click
    expect(page).to have_text(founder_1.name)
    expect(page).to have_text(founder_1.startup.name)
    fill_in 'Team Name', with: new_name, fill_options: { clear: :backspace }
    click_button 'Update Student'
    expect(page).to have_text("Student updated successfully")
    find('.ui-pnotify-container').click
    founder_1.reload
    expect(founder_1.startup.name).to eq(new_name)

    # Form a Team
    check "#{name_1}_checkbox"
    check "#{name_2}_checkbox"
    click_button 'Group as Team'
    expect(page).to have_text("Teams updated successfully")
    find('.ui-pnotify-container').click
    founder_1.reload
    founder_2.reload
    expect(founder_1.startup.name).to eq(founder_2.startup.name)
    expect(page).to have_text(founder_1.startup.name)

    # Move out from a team
    check "#{name_1}_checkbox"
    click_button 'Move out from Team'
    expect(page).to have_text("Teams updated successfully")
    find('.ui-pnotify-container').click
    founder_1.reload
    founder_2.reload
    expect(founder_1.startup.id).not_to eq(founder_2.startup.id)

    # Mark a student as exited
    founder = startup_2.founders.last
    find("a", text: founder.name).click
    expect(page).to have_text(founder.name)
    expect(page).to have_text(founder.startup.name)
    within("div#dropped_out_buttons") do
      click_button 'Yes'
    end
    click_button 'Update Student'
    expect(page).to have_text("Student updated successfully")
    find('.ui-pnotify-container').click
    founder.reload
    expect(founder.exited).to eq(true)
  end
end
