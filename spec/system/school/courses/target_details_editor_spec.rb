require 'rails_helper'

feature 'Target Details Editor', js: true do
  include UserSpecHelper
  include NotificationHelper
  include MarkdownEditorHelper

  # Setup a course with few targets target, ...
  let!(:school) { create :school, :current }
  let!(:course) { create :course, school: school }
  let!(:school_admin) { create :school_admin, school: school }
  let!(:faculty) { create :faculty, school: school }
  let!(:course_author) { create :course_author, course: course, user: faculty.user }
  let!(:level_1) { create :level, :one, course: course }
  let!(:level_2) { create :level, :two, course: course }
  let!(:target_group_1) { create :target_group, level: level_1 }
  let!(:target_group_2) { create :target_group, level: level_2 }
  let!(:target_1_l1) { create :target, target_group: target_group_1 }
  let!(:target_1_l2) { create :target, target_group: target_group_2 }
  let!(:target_2_l2) { create :target, target_group: target_group_2 }
  let!(:evaluation_criterion) { create :evaluation_criterion, course: course }

  let(:link_to_complete) { Faker::Internet.url }
  let(:completion_instructions) { Faker::Lorem.sentence }
  let(:new_target_title) { Faker::Lorem.sentence }

  let(:quiz_question_1) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_1) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_2) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_3) { Faker::Lorem.sentence }
  let(:quiz_question_1_answer_option_3_hint) { Faker::Lorem.sentence }
  let(:quiz_question_2) { Faker::Lorem.sentence }
  let(:quiz_question_2_answer_option_1) { Faker::Lorem.sentence }
  let(:quiz_question_2_answer_option_2) { Faker::Lorem.sentence }

  scenario 'school admin modifies title and adds completion instruction to target' do
    sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text('Title')

    fill_in 'title', with: new_target_title, fill_options: { clear: :backspace }
    fill_in 'completion-instructions', with: completion_instructions

    click_button 'Update Target'
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.title).to eq(new_target_title)
    expect(target_1_l2.completion_instructions).to eq(completion_instructions)
  end

  scenario 'school admin updates a target as reviewed by faculty' do
    sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text('Title')

    fill_in 'title', with: new_target_title, fill_options: { clear: :backspace }

    within("div#evaluated") do
      click_button 'Yes'
    end

    expect(page).to_not have_button('Visit a link to complete the target.')
    expect(page).to have_text('Atleast one has to be selected')

    find("div[title='Select #{evaluation_criterion.display_name}']").click

    within("div#visibility") do
      click_button 'Live'
    end

    click_button 'Update Target'
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.title).to eq(new_target_title)
    expect(target_1_l2.visibility).to eq(Target::VISIBILITY_LIVE)
    expect(target_1_l2.evaluation_criteria.count).to eq(1)
    expect(target_1_l2.evaluation_criteria.first.name).to eq(evaluation_criterion.name)
  end

  scenario 'school admin updates a target to one with link to complete' do
    sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click

    expect(page).to have_text('Will a coach review submissions on this target?')

    within("div#evaluated") do
      click_button 'No'
    end

    within("div#method_of_completion") do
      click_button 'Visit a link to complete the target.'
    end

    fill_in 'Link to complete', with: link_to_complete

    click_button 'Update Target'
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    expect(target_1_l2.reload.link_to_complete).to eq(link_to_complete)
    expect(target_1_l2.reload.evaluation_criteria.count).to eq(0)
    expect(target_1_l2.reload.quiz).to eq(nil)
  end

  scenario 'school admin updates a target to one with quiz' do
    sign_in_user school_admin.user, referer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text('Title')

    within("div#evaluated") do
      click_button 'No'
    end

    within("div#method_of_completion") do
      click_button 'Take a quiz to complete the target.'
    end

    # Quiz Question 1
    replace_markdown(quiz_question_1)
    click_button 'Preview'
    fill_in 'quiz_question_1_answer_option_1', with: quiz_question_1_answer_option_1
    fill_in 'quiz_question_1_answer_option_2', with: quiz_question_1_answer_option_2
    find("a", text: "Add another Answer Option").click
    fill_in 'quiz_question_1_answer_option_3', with: quiz_question_1_answer_option_3

    within("div#quiz_question_1_answer_option_3_block") do
      click_button 'Mark as correct'
    end

    # Quiz Question 2
    find("a", text: "Add another Question").click
    replace_markdown(quiz_question_2)
    fill_in 'quiz_question_2_answer_option_1', with: quiz_question_2_answer_option_1
    fill_in 'quiz_question_2_answer_option_2', with: quiz_question_2_answer_option_2

    click_button 'Update Target'

    expect(page).to have_text("Target updated successfully")

    dismiss_notification

    target = target_1_l2.reload

    expect(target.evaluation_criteria).to eq([])
    expect(target.link_to_complete).to eq(nil)
    expect(target.quiz.quiz_questions.count).to eq(2)
    expect(target.quiz.quiz_questions.first.question).to eq(quiz_question_1)
    expect(target.quiz.quiz_questions.first.correct_answer.value).to eq(quiz_question_1_answer_option_3)
    expect(target.quiz.quiz_questions.last.question).to eq(quiz_question_2)
    expect(target.quiz.quiz_questions.last.correct_answer.value).to eq(quiz_question_2_answer_option_1)
  end

  scenario 'course author modifies target role and prerequisite targets' do
    sign_in_user course_author.user, referer: curriculum_school_course_path(course)

    # Open the details editor for the target.
    find("a[title='Edit details of target #{target_1_l2.title}']").click
    expect(page).to have_text('Are there any prerequisite targets?')

    within("div#prerequisite_targets") do
      expect(page).to have_text(target_2_l2.title)
      expect(page).to_not have_text(target_1_l1.title)
      find("div[title='Select #{target_2_l2.title}']").click
    end

    click_button 'Only one student in a team needs to submit.'

    click_button 'Update Target'
    expect(page).to have_text("Target updated successfully")
    dismiss_notification

    target = target_1_l2.reload
    expect(target.role).to eq(Target::ROLE_TEAM)
    expect(target.prerequisite_targets.count).to eq(1)
    expect(target.prerequisite_targets.first).to eq(target_2_l2)
  end
end
