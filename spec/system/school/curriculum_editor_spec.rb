require 'rails_helper'

feature 'Curriculum Editor' do
  include UserSpecHelper

  # Setup a course with a single founder target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_group_2) { create :target_group, level: level_2 }
  let!(:target_1) { create :target, target_group: target_group_1 }
  let!(:target_2) { create :target, target_group: target_group_1 }
  let!(:target_3) { create :target, target_group: target_group_2 }
  let!(:target_4) { create :target, target_group: target_group_2 }

  # Data for level
  let(:new_level_name) { Faker::Lorem.sentence }
  let(:date) { Date.today }

  # Data for target group
  let(:new_target_group_name) { Faker::Lorem.sentence }
  let(:new_target_group_description) { Faker::Lorem.sentence }

  # Data for a normal target
  let(:new_target_1_title) { Faker::Lorem.sentence }
  let(:new_target_1_description) { Faker::Lorem.paragraphs.join(" ") }

  # Data for a mark as complete target
  let(:new_target_2_title) { Faker::Lorem.sentence }
  let(:new_target_2_description) { Faker::Lorem.paragraphs.join(" ") }

  # Data for a target with link to complete
  let(:new_target_3_title) { Faker::Lorem.sentence }
  let(:new_target_3_description) { Faker::Lorem.paragraphs.join(" ") }
  let(:link_to_complete) { Faker::Internet.url }

  # Data for a target with quiz
  let(:new_target_4_title) { Faker::Lorem.sentence }
  let(:new_target_4_description) { Faker::Lorem.paragraphs.join(" ") }

  let(:quiz_question_1) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_1) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_2) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_3) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_3_hint) { Faker::Lorem.sentence }

  let(:quiz_question_2) { Faker::Lorem.sentence }
  let(:quiz_question_2_answer_option_1) { Faker::Lorem.sentence }
  let(:quiz_question_2_answer_option_2) { Faker::Lorem.sentence }

  before do
    # Create a domain for school
    create :domain, :primary, school: school
  end

  scenario 'school admin create a course', js: true do
    sign_in_user school_admin.user, referer: school_course_path(course)
    click_link 'Curriculum'

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
    click_button 'Create New Level'
    expect(page).to have_text("Level Name")
    fill_in 'Level Name', with: new_level_name
    fill_in 'Unlock level on', with: date.day.to_s + "/" + date.month.to_s + "/" + date.year.to_s
    click_button 'Create Level'
    expect(page).to have_text("Level created successfully")

    course.reload
    level = course.levels.last
    expect(level.name).to eq(new_level_name)
    expect(level.unlock_on).to eq(date)

    # he should be able to edit the level
    click_button 'edit'
    expect(page).to have_text(new_level_name)
    fill_in 'Unlock level on', with: '', fill_options: { clear: :backspace }
    click_button 'Update Level'
    expect(page).to have_text("Level updated successfully")

    level.reload
    expect(level.unlock_on).not_to eq(date)

    # he should be able to create a new target group
    find('.target-group__create').click
    expect(page).to have_text("TARGET GROUP DETAILS")
    fill_in 'Title', with: new_target_group_name
    fill_in 'Description', with: new_target_group_description
    click_button 'Yes'
    click_button 'Create Target Group'
    expect(page).to have_text("Target Group created successfully")

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

    target_group.reload
    expect(target_group.description).not_to eq(new_target_group_description)
    expect(target_group.milestone).to eq(false)

    # he should be able to create a target with evaluation criteria and resources
    find('.target-group__target-create').click
    expect(page).to have_text("TARGET DETAILS")
    fill_in 'Title', with: new_target_1_title
    find('trix-editor').click.set new_target_1_description
    fill_in 'resource_title', with: 'A PDF File'
    attach_file 'Choose file to upload', File.absolute_path(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')), visible: false
    click_button 'Add Resource'
    expect(page).to have_text('Add Resource')
    expect(page).to have_text('A PDF File')

    find("a", text: "Add URL").click
    fill_in 'resource_title', with: 'A Link'
    fill_in 'link', with: 'https://www.sv.co'
    click_button 'Add Resource'
    expect(page).to have_text('Add Resource')
    expect(page).to have_text('A Link')

    within("div#evaluated") do
      click_button 'Yes'
    end
    click_button 'Create Target'

    expect(page).to have_text("Target created successfully")
    target_group.reload
    target = target_group.targets.last
    expect(target.title).to eq(new_target_1_title)
    expect(target.description).to eq("<div>" + new_target_1_description + "</div>")
    expect(target.evaluation_criteria.last.name).to eq(evaluation_criterion.name)
    expect(target.resources.count).to eq(2)
    expect(target.resources.pluck(:title)).to eq(['A PDF File', 'A Link'])
  end

  scenario "Admin creates a target with a link to complete", js: true do
    sign_in_user school_admin.user, referer: school_course_curriculum_path(course)

    find('.target-group__target-create').click
    expect(page).to have_text("TARGET DETAILS")
    fill_in 'Title', with: new_target_3_title
    find('trix-editor').click.set new_target_3_description
    within("div#evaluated") do
      click_button 'No'
    end
    within("div#method_of_completion") do
      click_button 'Visit a link to complete the target.'
    end
    fill_in 'Link to complete', with: link_to_complete
    click_button 'Create Target'

    expect(page).to have_text("Target created successfully")
    expect(page).to have_text("Create a target")
    target = Target.find_by(title: new_target_3_title)
    expect(target.description).to eq("<div>" + new_target_3_description + "</div>")
    expect(target.evaluation_criteria).to eq([])
    expect(target.link_to_complete).to eq(link_to_complete)
    expect(target.quiz).to eq(nil)
  end

  scenario "Admin creates a target with a quiz and updates it", js: true do
    sign_in_user school_admin.user, referer: school_course_curriculum_path(course)

    find('.target-group__target-create').click
    expect(page).to have_text("TARGET DETAILS")
    fill_in 'Title', with: new_target_4_title
    find('trix-editor').click.set new_target_4_description

    within("div#evaluated") do
      click_button 'No'
    end

    within("div#method_of_completion") do
      click_button 'Take a quiz to complete the target.'
    end

    # Quiz Question 1
    fill_in 'Question 1', with: quiz_question_1
    fill_in 'quiz_question_1_answer_option_1', with: quiz_question_1_answer_option_1
    fill_in 'quiz_question_1_answer_option_2', with: quiz_question_1_answer_option_2
    find("a", text: "Add another Answer Option").click
    fill_in 'quiz_question_1_answer_option_3', with: quiz_question_1_answer_option_3

    within("div#quiz_question_1_answer_option_3_block") do
      click_button 'Mark as correct'
      click_button 'Explain'
    end

    fill_in 'quiz_question_1_answer_option_3_hint', with: quiz_question_1_answer_option_3_hint

    within("div#quiz_question_1_answer_option_3_block") do
      click_button 'Explain'
    end

    # Quiz Question 2
    find("a", text: "Add another Question").click
    fill_in 'Question 2', with: quiz_question_2
    fill_in 'quiz_question_2_answer_option_1', with: quiz_question_2_answer_option_1
    fill_in 'quiz_question_2_answer_option_2', with: quiz_question_2_answer_option_2

    click_button 'Create Target'

    expect(page).to have_text("Target created successfully")
    expect(page).to have_text("Create a target")
    target = Target.find_by(title: new_target_4_title)
    expect(target.description).to eq("<div>" + new_target_4_description + "</div>")
    expect(target.evaluation_criteria).to eq([])
    expect(target.link_to_complete).to eq(nil)
    expect(target.quiz.title).to eq(new_target_4_title)
    expect(target.quiz.quiz_questions.count).to eq(2)
    expect(target.quiz.quiz_questions.first.question).to eq(quiz_question_1)
    expect(target.quiz.quiz_questions.first.correct_answer.value).to eq(quiz_question_1_answer_option_3)
    expect(target.quiz.quiz_questions.last.question).to eq(quiz_question_2)
    expect(target.quiz.quiz_questions.last.correct_answer.value).to eq(quiz_question_2_answer_option_1)

    find('.target-group__target', text: new_target_4_title).click
    expect(page).to have_text("TARGET DETAILS")
    within("div#evaluated") do
      click_button 'No'
    end
    within("div#method_of_completion") do
      click_button 'Simply mark the target as completed.'
    end
    click_button 'Update Target'

    expect(page).to have_text("Target updated successfully")
    target.reload
    expect(target.evaluation_criteria).to eq([])
    expect(target.link_to_complete).to eq(nil)
    expect(target.quiz).to eq(nil)
  end
end
