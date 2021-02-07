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
  let(:target_group_l1) { create :target_group, level: level_1, milestone: true }
  let!(:target_l0) { create :target, :with_group, level: level_0 }
  let!(:target_l1) { create :target, :with_content, target_group: target_group_l1, role: Target::ROLE_TEAM, evaluation_criteria: [criterion_1, criterion_2], completion_instructions: Faker::Lorem.sentence }
  let!(:target_l2) { create :target, :with_content, :with_group, level: level_2, milestone: true, role: Target::ROLE_TEAM, evaluation_criteria: [criterion_1, criterion_2], completion_instructions: Faker::Lorem.sentence }

  Rspec.shared_examples 'student is limited to current level' do
    scenario 'student cannot level up' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_text(target.title)
      expect(page).to have_text("You're at Level #{target.level.number}, but you have targets in the Level 1 that have been rejected, or are pending review by a coach.")
      expect(page).to have_text("You'll need to pass all milestone targets in Level 1 to continue leveling up.")
      expect(page).not_to have_button('Level Up')
    end
  end

  context 'when the course has progression limited to one level' do
    scenario 'student on level 1 can level up immediately after submitting the milestone targets, except when previous level milestones are incomplete' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      # Student cannot level up yet.
      expect(page).to have_text(target_l1.title)
      expect(page).not_to have_button('Level Up')

      # Let's submit work on the target in L1.
      click_link target_l1.title
      find('.course-overlay__body-tab-item', text: 'Complete').click

      expect(page).to have_text(target_l1.completion_instructions)

      click_button 'Complete'

      expect(page).to have_content('Your submission has been queued for review')

      # Let's check the curriculum view to make sure that only the level up option is visible now.
      click_button 'Close'

      expect(page).not_to have_text(target_l1.title)
      expect(page).not_to have_text(target_group_l1.name)
      expect(page).not_to have_button('Next Level')

      expect(page).to have_text('You have successfully completed all milestone targets')

      # Reload the page, it should still remain the same.
      visit curriculum_course_path(course)

      expect(page).to have_text('You have successfully completed all milestone targets')
      expect(page).not_to have_text(target_l1.title)
      expect(page).not_to have_text(target_group_l1.name)

      click_button('Level Up')

      expect(page).to have_link(target_l2.title)
      expect(team.reload.level).to eq(level_2)
    end

    context 'when a student is in level 2 and has completed all milestone targets there' do
      let(:team) { create :startup, level: level_2 }

      before do
        complete_target target_l2, student
      end

      context 'when student has a milestone target with a submission pending review in level 1' do
        let(:target) { target_l2 }

        before do
          submit_target target_l1, student
        end

        include_examples 'student is limited to current level'
      end

      context 'when student has a milestone target with a failed submission in level 1' do
        let(:target) { target_l2 }

        before do
          submit_target target_l1, student, grade: SubmissionsHelper::GRADE_FAIL
        end

        include_examples 'student is limited to current level'
      end

      context 'when the student has passed all milestone targets in level 1' do
        before do
          complete_target target_l1, student
        end

        scenario 'student is shown the option to level up again' do
          sign_in_user student.user, referrer: curriculum_course_path(course)

          expect(page).to have_button('Level Up')
        end
      end
    end
  end

  context 'when the course has progression limited to three levels' do
    let(:course) { create :course, progression_limit: 3 }
    let(:level_4) { create :level, :four, course: course }
    let!(:level_5) { create :level, :five, course: course }
    let(:target_l3) { create :target, :with_content, :with_group, :team, level: level_3, milestone: true, evaluation_criteria: [criterion_1] }
    let!(:target_l4) { create :target, :with_content, :with_group, :team, level: level_4, milestone: true, evaluation_criteria: [criterion_1] }

    context 'when team is in the third level and all milestone targets have been submitted' do
      let(:team) { create :startup, level: level_3 }

      before do
        submit_target target_l1, student
        submit_target target_l2, student
        submit_target target_l3, student
      end

      scenario 'student levels up' do
        sign_in_user student.user, referrer: curriculum_course_path(course)

        click_button('Level Up')

        expect(page).to have_link(target_l4.title)
        expect(team.reload.level).to eq(level_4)
      end
    end

    context 'when team is in the fourth level and all milestone targets have been submitted' do
      let(:team) { create :startup, level: level_4 }
      let(:target) { target_l4 }

      before do
        submit_target target_l1, student
        submit_target target_l2, student
        submit_target target_l3, student
        submit_target target_l4, student
      end

      include_examples 'student is limited to current level'
    end
  end

  context 'when course progression is unlimited and team is in fourth level with all milestone targets submitted' do
    let(:course) { create :course, :unlimited }
    let(:level_4) { create :level, :four, course: course }
    let(:level_5) { create :level, :five, course: course }
    let(:team) { create :startup, level: level_4 }
    let(:target_l3) { create :target, :with_content, :with_group, :team, level: level_3, milestone: true, evaluation_criteria: [criterion_1] }
    let(:target_l4) { create :target, :with_content, :with_group, :team, level: level_4, milestone: true, evaluation_criteria: [criterion_1] }
    let!(:target_l5) { create :target, :with_content, :with_group, :team, level: level_5, milestone: true, evaluation_criteria: [criterion_1] }

    before do
      submit_target target_l1, student
      submit_target target_l2, student
      submit_target target_l3, student
      submit_target target_l4, student
    end

    scenario 'student levels up' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      click_button('Level Up')

      expect(page).to have_link(target_l5.title)
      expect(team.reload.level).to eq(level_5)
    end
  end

  context 'when course progression is strict' do
    let(:course) { create :course, :strict }

    context 'when the student has submitted all milestone targets' do
      before do
        submit_target target_l1, student
      end

      scenario 'student with a submission pending review is blocked from leveling up' do
        sign_in_user student.user, referrer: curriculum_course_path(course)

        expect(page).to have_text('Pending Review')
        expect(page).to have_text("You have submitted all milestone targets in level 1, but one or more submissions are pending review by a coach")
        expect(page).to have_text("You need to get a passing grade on all milestone targets to level up.")
        expect(page).not_to have_button('Level Up')
      end
    end

    context 'when the student has failed a milestone target' do
      before do
        fail_target target_l1, student
      end

      scenario 'student with a rejected submission is blocked from leveling up' do
        sign_in_user student.user, referrer: curriculum_course_path(course)

        expect(page).to have_text('Level Up Blocked')
        expect(page).to have_text("You have submitted all milestone targets in level 1, but one or more submissions have been rejected")
        expect(page).to have_text("You need to get a passing grade on all milestone targets to level up.")
        expect(page).not_to have_button('Level Up')
      end
    end

    context 'when the student has passed all milestone targets' do
      before do
        complete_target target_l1, student
      end

      scenario 'student levels up' do
        sign_in_user student.user, referrer: curriculum_course_path(course)

        click_button('Level Up')

        expect(page).to have_link(target_l2.title)
        expect(team.reload.level).to eq(level_2)
      end
    end
  end

  context "when a teammate hasn't completed all milestone targets" do
    let!(:target_l1) { create :target, :with_content, :student, target_group: target_group_l1 }

    before do
      complete_target target_l1, student
    end

    scenario 'student is blocked from leveling up until teammate submits work on target' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_text('Check With Your Team')
      expect(page).to have_text("You have completed all required milestone targets, but one or more of your team-mates haven't. Please ask them to sign in and check for incomplete milestone targets.")
      expect(page).not_to have_button('Level Up')

      team.founders.where.not(id: student.id).each do |other_student|
        submit_target target_l1, other_student
      end

      visit curriculum_course_path(course)
      click_button('Level Up')

      expect(page).to have_link(target_l2.title)
      expect(team.reload.level.number).to eq(2)
    end

    context "when a teammate hasn't completed milestone targets in a previous level" do
      let(:team) { create :startup, level: level_1 }

      before do
        # 'This' student has completed all required milestone targets.
        complete_target target_l1, student

        # Teammates has completed milestone target only in current level.
        team.founders.each do |student|
          complete_target target_l2, student
        end
      end

      scenario 'student is blocked from leveling up until teammate submits work on target in previous level' do
        sign_in_user student.user, referrer: curriculum_course_path(course)

        expect(page).to have_text('Check With Your Team')
        expect(page).to have_text("You have completed all required milestone targets, but one or more of your team-mates haven't. Please ask them to sign in and check for incomplete milestone targets.")
        expect(page).not_to have_button('Level Up')
      end
    end

    context 'when course progression is strict' do
      let(:course) { create :course, :strict }
      let!(:target_l1) { create :target, :with_content, :student, target_group: target_group_l1, evaluation_criteria: [criterion_1, criterion_2] }

      before do
        complete_target target_l1, student
      end

      scenario 'student is blocked from leveling up until teammate gets passing grade on milestone targets' do
        sign_in_user student.user, referrer: curriculum_course_path(course)

        expect(page).to have_text('Check With Your Team')
        expect(page).to have_text("You have completed all required milestone targets, but one or more of your team-mates haven't. Please ask them to sign in and check for incomplete milestone targets.")
        expect(page).not_to have_button('Level Up')

        # Submitting the targets should not result in any change.
        team.founders.where.not(id: student.id).each do |other_student|
          submit_target target_l1, other_student
        end

        visit curriculum_course_path(course)

        expect(page).to have_text('Check With Your Team')

        # Completing the targets should result in allowing the team to level up.
        team.founders.where.not(id: student.id).each do |other_student|
          other_student.timeline_events.where(target_id: target_l1.id).destroy_all
          complete_target target_l1, other_student
        end

        visit curriculum_course_path(course)

        click_button('Level Up')

        expect(page).to have_link(target_l2.title)
        expect(team.reload.level.number).to eq(2)
      end
    end

    context 'when course progression is unlimited' do
      let(:course) { create :course, :unlimited }

      before do
        submit_target target_l1, student
      end

      scenario "student is blocked from leveling up until teammate submits work for milestone targets" do
        sign_in_user student.user, referrer: curriculum_course_path(course)

        expect(page).to have_text('Check With Your Team')
        expect(page).to have_text("You have completed all required milestone targets, but one or more of your team-mates haven't. Please ask them to sign in and check for incomplete milestone targets.")
        expect(page).not_to have_button('Level Up')

        # Submitting the targets should result in allowing the team to level up.
        team.founders.where.not(id: student.id).each do |other_student|
          submit_target target_l1, other_student
        end

        visit curriculum_course_path(course)
        click_button('Level Up')

        expect(page).to have_link(target_l2.title)
        expect(team.reload.level.number).to eq(2)
      end
    end
  end

  context 'when a student is in level 1 and has completed all milestone targets there, but level 2 is locked' do
    let(:level_2) { create :level, :two, course: course, unlock_at: 1.week.from_now }

    before do
      complete_target target_l1, student
    end

    scenario 'regular student cannot level up' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_text(target_l1.title)
      expect(page).not_to have_button('Level Up')
    end

    context 'when the user is a school admin' do
      before do
        create :school_admin, user: student.user, school: student.school
      end

      scenario 'school admin levels up to locked level' do
        sign_in_user student.user, referrer: curriculum_course_path(course)
        click_button('Level Up')

        expect(page).to have_link(target_l2.title)
      end
    end

    context 'when the user is a coach in the course' do
      let(:coach) { create :faculty, user: student.user }

      before do
        create :faculty_startup_enrollment, :with_course_enrollment, faculty: coach, startup: team
      end

      scenario 'coach levels up to locked level' do
        sign_in_user student.user, referrer: curriculum_course_path(course)
        click_button('Level Up')

        expect(page).to have_link(target_l2.title)
      end
    end
  end

  context "when a level doesn't have any milestone target group" do
    let!(:target_group_l1) { create :target_group, level: level_1, milestone: false }

    before do
      complete_target target_l1, student
    end

    scenario 'student cannot level up' do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      # Student should be on shown level 1.
      expect(page).to have_text(target_l1.title)

      # The target should be passed...
      expect(page).to have_text('Completed', count: 1)

      # ...but there shouldn't be any option to level up.
      expect(page).not_to have_text('You have successfully completed all milestone targets')
      expect(page).not_to have_button('Level Up')
    end
  end

  context 'when a student is at the last level with all milestone targets in that level completed' do
    let(:team) { create :startup, level: level_3 }
    let(:target_l3) { create :target, :with_content, :with_group, level: level_3, milestone: true, role: Target::ROLE_TEAM }

    before do
      complete_target target_l3, student
    end

    scenario "student sees a notice that they've completed the course" do
      sign_in_user student.user, referrer: curriculum_course_path(course)

      expect(page).to have_text('You have completed all milestone targets in the final level')
      expect(page).to have_text("You've completed our coursework")
    end
  end
end
