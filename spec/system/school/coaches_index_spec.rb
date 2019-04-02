require 'rails_helper'

feature 'Coaches Index' do
  include UserSpecHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:coach_1) { create :faculty, school: school }
  let!(:coach_2) { create :faculty, school: school }

  let!(:new_coach_name) { Faker::Lorem.words(2).join ' ' }
  let!(:new_coach_email) { Faker::Internet.email }
  let!(:new_coach_title) { Faker::Lorem.words(2).join ' ' }

  let!(:updated_coach_name) { Faker::Lorem.words(2).join ' ' }
  let!(:updated_coach_title) { Faker::Lorem.words(2).join ' ' }

  let!(:school_admin) { create :school_admin, school: school }

  before do
    # Create a domain for school
    create :domain, :primary, school: school
  end

  scenario 'school admin visits coaches and creates a coach', js: true do
    sign_in_user school_admin.user, referer: school_coaches_path

    # list all coaches
    expect(page).to have_text("Add New Coach")
    expect(page).to have_text(coach_1.name)
    expect(page).to have_text(coach_2.name)

    # Add a new course
    click_button 'Add New Coach'

    fill_in 'Name', with: new_coach_name
    fill_in 'Email', with: new_coach_email
    fill_in 'Title', with: new_coach_title
    fill_in 'LinkedIn', with: 'https://www.linkedin.com/xyz'
    fill_in 'Connect Link', with: 'https://www.connect.com/xyz'

    click_button 'Create Coach'

    expect(page).to have_text("Coach created successfully")
    find('.ui-pnotify-container').click
    expect(page).to have_text(new_coach_name)
    coach = Faculty.last
    expect(coach.name).to eq(new_coach_name)
    expect(coach.title).to eq(new_coach_title)
    expect(coach.user.email).to eq(new_coach_email)
    expect(coach.linkedin_url).to eq('https://www.linkedin.com/xyz')
    expect(coach.connect_link).to eq('https://www.connect.com/xyz')

    find("p", text: new_coach_name).click
    fill_in 'Name', with: updated_coach_name
    fill_in 'Title', with: updated_coach_title
    click_button 'Update Coach'
    expect(page).to have_text("Coach updated successfully")
    coach.reload
    expect(coach.name).to eq(updated_coach_name)
    expect(coach.title).to eq(updated_coach_title)
  end
end
