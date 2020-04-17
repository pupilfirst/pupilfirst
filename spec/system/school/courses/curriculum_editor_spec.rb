require 'rails_helper'

feature 'Curriculum Editor', js: true do
  include UserSpecHelper
  include MarkdownEditorHelper
  include NotificationHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:course_2) { create :course, school: school }
  let!(:course_3) { create :course, school: school }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:faculty) { create :faculty, school: school }
  let!(:course_author) { create :course_author, course: course, user: faculty.user }
  let!(:course_author_2) { create :course_author, course: course_2, user: faculty.user }
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_group_2) { create :target_group, level: level_2 }
  let!(:target_1) { create :target, target_group: target_group_1 }
  let!(:target_2) { create :target, target_group: target_group_1 }
  let!(:target_3) { create :target, target_group: target_group_2 }
  let!(:target_4) { create :target, target_group: target_group_2 }
  # Target with contents
  let!(:target_5) { create :target, :with_content, target_group: target_group_2 }

  # Data for level
  let(:new_level_name) { Faker::Lorem.sentence }
  let(:date) { Date.today }

  # Data for target group 1
  let(:new_target_group_name) { Faker::Lorem.sentence }
  let(:new_target_group_description) { Faker::Lorem.sentence }

  # Data for target group 2
  let(:new_target_group_name_2) { Faker::Lorem.sentence }

  # Data for a normal target
  let(:new_target_1_title) { Faker::Lorem.sentence }

  scenario 'admin creates a basic course framework by adding level, target group and targets' do
    sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

    # he should be on the last level
    expect(page).to have_text("Level 2: " + level_2.name)

    # all targets and target groups on that level should be visible
    expect(page).to have_text(target_group_2.name)
    expect(page).to have_text(target_3.title)
    expect(page).to have_text(target_4.title)

    # targets and target groups from other levels should not be visible
    expect(page).not_to have_text(target_group_1.name)
    expect(page).not_to have_text(target_1.title)
    expect(page).not_to have_text(target_2.title)

    # he should be able to create a new level
    click_button 'Create Level'
    expect(page).to have_text("Level Name")
    fill_in 'Level Name', with: new_level_name
    fill_in 'Unlock level on', with: date.iso8601
    click_button 'Create New Level'

    expect(page).to have_text("Level created successfully")
    dismiss_notification

    level = course.reload.levels.last
    expect(level.name).to eq(new_level_name)
    expect(level.unlock_on).to eq(date)

    # he should be able to edit the level
    click_button 'edit'
    expect(page).to have_text(new_level_name)
    fill_in 'Unlock level on', with: '', fill_options: { clear: :backspace }
    click_button 'Update Level'

    expect(page).to have_text('Level updated successfully')
    dismiss_notification

    expect(level.reload.unlock_on).to eq(nil)

    # he should be able to create a new target group
    find('.target-group__create').click
    expect(page).to have_text('TARGET GROUP DETAILS')
    fill_in 'Title', with: new_target_group_name
    fill_in 'Description', with: new_target_group_description
    click_button 'Yes'
    click_button 'Create Target Group'

    expect(page).to have_text('Target Group created successfully')
    dismiss_notification

    level.reload
    target_group = level.target_groups.last
    expect(target_group.name).to eq(new_target_group_name)
    expect(target_group.description).to eq(new_target_group_description)
    expect(target_group.milestone).to eq(true)

    # he should be able to update a target group
    find('.target-group__header', text: target_group.name).click
    expect(page).to have_text(target_group.name)
    expect(page).to have_text(target_group.description)
    fill_in 'Description', with: '', fill_options: { clear: :backspace }

    within('.milestone') do
      click_button 'No'
    end

    click_button 'Update Target Group'

    expect(page).to have_text("Target Group updated successfully")
    dismiss_notification

    target_group.reload
    expect(target_group.description).not_to eq(new_target_group_description)
    expect(target_group.milestone).to eq(false)

    # he should be able to create another target group
    find('.target-group__create').click
    expect(page).to have_text('TARGET GROUP DETAILS')
    fill_in 'Title', with: new_target_group_name_2
    click_button 'Yes'
    click_button 'Create Target Group'

    expect(page).to have_text('Target Group created successfully')
    dismiss_notification

    # Update sort index
    find("#target-group-move-down-#{target_group.id}").click
    expect { target_group.reload.sort_index }.to eventually(eq 1)

    sleep 0.2

    find("#target-group-move-up-#{target_group.id}").click
    expect { target_group.reload.sort_index }.to eventually(eq 0)

    sleep 0.2

    # user should be able to create a draft target from the curriculum index
    find("#create-target-input#{target_group.id}").click
    fill_in "create-target-input#{target_group.id}", with: new_target_1_title
    click_button 'Create'

    expect(page).to have_text('Target created successfully')
    dismiss_notification

    target = target_group.reload.targets.last

    expect(target.title).to eq(new_target_1_title)
    expect(page).to have_text(new_target_1_title)

    within("a#target-show-#{target.id}") do
      expect(page).to have_text('Draft')
    end
  end

  scenario 'course author can navigate only to assigned courses and modify content of those courses' do
    sign_in_user course_author.user, referer: curriculum_school_course_path(course)

    click_button course.name

    expect(page).to have_link(course_2.name, href: "/school/courses/#{course_2.id}/curriculum")
    expect(page).to_not have_link(course_3.name, href: "/school/courses/#{course_3.id}/curriculum")

    click_link course_2.name

    expect(page).to have_button(course_2.name)
    expect(page).to_not have_link(href: '/school/coaches')
    expect(page).to_not have_link(href: '/school/customize')
    expect(page).to_not have_link(href: '/school/courses')
    expect(page).to_not have_link(href: '/school/communities')
    expect(page).to have_link(href: '/home')

    [school_path, curriculum_school_course_path(course_3), school_communities_path, school_courses_path, customize_school_path].each do |path|
      visit path

      expect(page).to have_text("The page you were looking for doesn't exist!")
    end

    visit curriculum_school_course_path(course)
    find("#create-target-input#{target_group_2.id}").click
    fill_in "create-target-input#{target_group_2.id}", with: new_target_1_title
    click_button 'Create'

    expect(page).to have_text("Target created successfully")

    dismiss_notification
  end

  scenario 'user who is not logged in gets redirected to sign in page' do
    visit curriculum_school_course_path(course)

    expect(page).to have_text("Please sign in to continue.")
  end
end
