require 'rails_helper'

feature "Student levelling up", js: true do
  include UserSpecHelper
  include SubmissionsHelper

  let(:course) { create :course }
  let(:criterion_1) { create :evaluation_criterion, course: course }
  let(:criterion_2) { create :evaluation_criterion, course: course }
  let(:level_0) { create :level, :zero, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let!(:level_3) { create :level, :three, course: course }
  let(:team) { create :startup, level: level_1 }
  let(:student) { team.founders.first }
  let(:target_group_l0) { create :target_group, level: level_0 }
  let(:target_group_l1) { create :target_group, level: level_1, milestone: true }
  let(:target_group_l2) { create :target_group, level: level_2, milestone: true }
  let!(:target_l0) { create :target, target_group: target_group_l0 }
  let!(:target_l1) { create :target, :with_content, target_group: target_group_l1, role: Target::ROLE_TEAM, evaluation_criteria: [criterion_1, criterion_2], completion_instructions: Faker::Lorem.sentence }
  let!(:target_l2) { create :target, :with_content, target_group: target_group_l2, role: Target::ROLE_TEAM, evaluation_criteria: [criterion_1, criterion_2], completion_instructions: Faker::Lorem.sentence }

  Rspec.shared_examples "student is blocked from leveling up" do
    scenario 'student cannot level up' do
      sign_in_user student.user, referer: curriculum_course_path(course)

      expect(page).to have_text(target_l2.title)
      expect(page).to have_text("You have targets in the previous level that are failed, or are pending review by a coach.")
      expect(page).to have_text("You're done with this level, but you have targets in the last level that you haven't passed.")
      expect(page).to have_text("You can level up once all you have passed all targets in the last level.")
      expect(page).not_to have_button('Level Up')
    end
  end

  scenario 'student on level 1 can level up immediately after submitting the milestone targets, except when previous level milestones are incomplete' do
    sign_in_user student.user, referer: curriculum_course_path(course)

    # Student cannot level up yet.
    expect(page).to have_text(target_l1.title)
    expect(page).not_to have_button('Level Up')

    # Let's submit work on the target in L1.
    find("div[aria-label='Select Target #{target_l1.id}'").click
    find('.course-overlay__body-tab-item', text: 'Complete').click

    expect(page).to have_text(target_l1.completion_instructions)

    fill_in 'Work on your submission', with: Faker::Lorem.sentence
    click_button 'Submit'

    expect(page).to have_content('Your submission has been queued for review')

    # Let's check the curriculum view to make sure that only the level up option is visible now.
    click_button 'Close'

    expect(page).not_to have_text(target_l1.title)
    expect(page).not_to have_text(target_group_l1.name)

    expect(page).to have_text('You have successfully completed all milestone targets required to level up.')

    # Reload the page, it should still remain the same.
    visit curriculum_course_path(course)

    expect(page).to have_text('You have successfully completed all milestone targets required to level up.')
    expect(page).not_to have_text(target_l1.title)
    expect(page).not_to have_text(target_group_l1.name)

    click_button('Level Up')

    expect(page).to have_text(target_l2.title)
    expect(team.reload.level).to eq(level_2)
  end

  context 'when a student is in level 2 has a target pending review in level 1' do
    before do
      submit_target target_l1, student
    end

    include_examples 'student is blocked from leveling up'
  end

  context 'when a student in in level 2 has a failed target in level 1' do
    before do
      submit_target target_l1, student, grade: SubmissionsHelper::GRADE_FAIL
    end

    include_examples 'student is blocked from leveling up'
  end

  context 'when a student in level 2 has passed all milestone targets in level 1' do
    before do
      complete_target target_l1, student
    end

    scenario 'student is shown the option to level up again' do
      sign_in_user student.user, referer: curriculum_course_path(course)

      expect(page).to have_button('Level Up')
    end
  end

  context "when a level doesn't have any milestone target group" do
    let!(:target_group_l1) { create :target_group, level: level_1, milestone: false }

    before do
      complete_target target_l1, student
    end

    scenario 'student cannot level up' do
      sign_in_user student.user, referer: curriculum_course_path(course)

      # Student should be on shown level 1.
      expect(page).to have_text(target_l1.title)

      # The target should be passed...
      expect(page).to have_text('Passed', count: 1)

      # ...but there shouldn't be any option to level up.
      expect(page).not_to have_text('You have successfully completed all milestone targets required to level up.')
      expect(page).not_to have_button('Level Up')
    end
  end
end
