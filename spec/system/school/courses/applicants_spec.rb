require 'rails_helper'

feature 'Applicant Index', js: true do
  include UserSpecHelper
  include NotificationHelper

  # Setup a course with a single student target, ...
  let!(:tags) { ['Pupilfirst'] }
  let!(:school) { create :school, :current,student_tag_list: tags }
  let!(:course) { create :course, :with_default_cohort, school: school }
  let!(:level_1) { create :level, :one, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:applicant_1) do
    create :applicant, :verified, course: course, name: 'Pupilfirst Applicant'
  end
  let!(:applicant_2) do
    create :applicant, :verified, course: course, tag_list: tags
  end

  context 'with many applicants' do
    before { 23.times { create :applicant, :verified, course: course } }

    scenario 'school admin loads all applicants' do
      sign_in_user school_admin.user,
                   referrer: applicants_school_course_path(course)

      expect(page).to have_text('Showing 10 of 25 applicants')
      click_button 'Load More Applicants...'

      expect(page).to have_text('Showing 20 of 25 applicants')
      click_button 'Load More Applicants...'

      expect(page).to have_text('Showing all 25 applicants')
      expect(page).not_to have_text('Load More Applicants...')
    end
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit applicants_school_course_path(course)
    expect(page).to have_text('Please sign in to continue.')
  end

  scenario 'school admin searches and filters applicants' do
    sign_in_user school_admin.user,
                 referrer: applicants_school_course_path(course)

    within("div[id='applicants']") do
      expect(page).to have_text(applicant_1.name)
      expect(page).to have_text(applicant_2.name)
    end

    fill_in('Search', with: 'Pupilfirst Applicant')
    click_button 'Pick Search by name or email: Pupilfirst Applicant'

    within("div[id='applicants']") do
      expect(page).to have_text(applicant_1.name)
      expect(page).not_to have_text(applicant_2.name)
    end

    click_button 'Remove selection: Pupilfirst Applicant'
    fill_in('Search', with: 'Pupilfirst')
    click_button 'Pick Tag: Pupilfirst'

    within("div[id='applicants']") do
      expect(page).not_to have_text(applicant_1.name)
      expect(page).to have_text(applicant_2.name)
    end
  end

  scenario 'school admin checks out applicants index' do
    sign_in_user school_admin.user,
                 referrer: applicants_school_course_path(course)

    within("div[id='applicants']") do
      expect(page).to have_text(applicant_1.name)
      expect(page).to have_text(applicant_1.email)
      expect(page).to have_text(applicant_2.tags.first)
    end

    click_button "Show Details: #{applicant_1.name}"

    within("div[applicant-id='#{applicant_1.id}']") do
      expect(page).to have_selector("input[value='#{applicant_1.name}']")
      expect(page).to have_selector("input[value='#{applicant_1.email}']")
    end
  end

  scenario 'school admin onboards an applicant' do
    sign_in_user school_admin.user,
                 referrer: applicants_school_course_path(course)

    click_button "Show Actions: #{applicant_1.name}"
    click_button 'Add as Student'
    expect(page).to have_text('Student created successfully.')
    dismiss_notification

    student = Student.last
    expect(student.name).to eq(applicant_1.name)
    expect(student.email).to eq(applicant_1.email)
    expect(student.title).to eq('Student')
  end

  scenario 'school admin onboards an applicant with additional data' do
    title_1 = Faker::Lorem.words(number: 2).join(' ')
    affiliation_1 = Faker::Lorem.words(number: 2).join(' ')

    sign_in_user school_admin.user,
                 referrer: applicants_school_course_path(course)

    click_button "Show Actions: #{applicant_1.name}"
    fill_in 'Title', with: title_1
    find('input[id="title"]').click
    fill_in 'Affiliation', with: affiliation_1
    fill_in 'Tags', with: 'Abc'
    find('button[title="Add new tag Abc"]').click
    fill_in 'Tags', with: 'Def'
    find('button[title="Add new tag Def"]').click
    click_button 'Add as Student'
    expect(page).to have_text('Student created successfully.')
    dismiss_notification

    student = Student.last
    open_email(applicant_1.email)
    expect(student.name).to eq(applicant_1.name)
    expect(student.email).to eq(applicant_1.email)
    expect(student.title).to eq(title_1)
    expect(student.affiliation).to eq(affiliation_1)
    expect(student.tag_list).to contain_exactly('Abc', 'Def')
  end
end
