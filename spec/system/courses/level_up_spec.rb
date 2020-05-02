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
      sign_in_user student.user, referer: curriculum_course_path(course)

      expect(page).to have_text(target.title)
      expect(page).to have_text("You're at Level #{target.level.number}, but you have targets in the Level 1 that are failed, or are pending review by a coach.")
      expect(page).to have_text("You'll need to pass all milestone targets in Level 1 to continue leveling up.")
      expect(page).not_to have_button('Level Up')
    end
  end

  context 'when the course has progression limited to one level' do
    scenario 'student on level 1 can level up immediately after submitting the milestone targets, except when previous level milestones are incomplete' do
      sign_in_user student.user, referer: curriculum_course_path(course)

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

      expect(page).to have_text('You have successfully completed all milestone targets required to level up.')

      # Reload the page, it should still remain the same.
      visit curriculum_course_path(course)

      expect(page).to have_text('You have successfully completed all milestone targets required to level up.')
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
          sign_in_user student.user, referer: curriculum_course_path(course)

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
        sign_in_user student.user, referer: curriculum_course_path(course)

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

  context 'when the course has unlimited progression and team is in fourth level with all milestone targets submitted' do
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
      sign_in_user student.user, referer: curriculum_course_path(course)

      click_button('Level Up')

      expect(page).to have_link(target_l5.title)
      expect(team.reload.level).to eq(level_5)
    end
  end

  context 'when the course has locked progression' do
    let(:course) { create :course, :locked }

    context 'when the student has submitted all milestone targets' do
      before do
        submit_target target_l1, student
      end

      scenario 'student is locked in current level' do
        sign_in_user student.user, referer: curriculum_course_path(course)

        expect(page).to have_text(target_l1.title)
        expect(page).to have_text("You have submitted all milestone targets in level 1, but one or more submissions are pending review by a coach.")
        expect(page).to have_text("You need to get a passing grade on all milestone targets to level up.")
        expect(page).not_to have_button('Level Up')
      end
    end

    context 'when the student has failed a milestone target' do
      before do
        fail_target target_l1, student
      end

      scenario 'student cannot level up' do
        sign_in_user student.user, referer: curriculum_course_path(course)

        expect(page).to have_text('Failed')
        expect(page).not_to have_button('Level Up')
      end
    end

    context 'when the student has passed all milestone targets' do
      before do
        complete_target target_l1, student
      end

      scenario 'student levels up' do
        sign_in_user student.user, referer: curriculum_course_path(course)

        click_button('Level Up')

        expect(page).to have_link(target_l2.title)
        expect(team.reload.level).to eq(level_2)
      end
    end
  end

  context 'when a student is in level 1 and has completed all milestone targets there, but level 2 is locked' do
    let(:level_2) { create :level, :two, course: course, unlock_on: 1.week.from_now }

    before do
      complete_target target_l1, student
    end

    scenario 'regular student cannot level up' do
      sign_in_user student.user, referer: curriculum_course_path(course)

      expect(page).to have_text(target_l1.title)
      expect(page).not_to have_button('Level Up')
    end

    context 'when the user is a school admin' do
      before do
        create :school_admin, user: student.user, school: student.school
      end

      scenario 'school admin levels up to locked level' do
        sign_in_user student.user, referer: curriculum_course_path(course)
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
        sign_in_user student.user, referer: curriculum_course_path(course)
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
