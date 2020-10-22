require 'rails_helper'

describe Students::LevelUpEligibilityService do
  include SubmissionsHelper

  subject { described_class.new(student) }

  let(:course_1) { create :course }
  let!(:course_2) { create :course }
  let(:evaluation_criterion) { create :evaluation_criterion, course: course_1 }
  let(:level_1) { create :level, :one, course: course_1 }
  let!(:level_2) { create :level, :two, unlock_at: 5.days.ago, course: course_1 }
  let!(:level_2_c2) { create :level, :two, unlock_at: 2.days.from_now, course: course_2 }
  let(:startup) { create :startup, level: level_1 }
  let(:student) { startup.founders.first }
  let(:students) { startup.founders }
  let!(:milestone_targets) { create :target_group, level: level_1, milestone: true }
  let!(:team_target) { create :target, :for_team, target_group: milestone_targets }
  let!(:non_milestone_team_target) { create :target, :for_team, :with_group, level: level_1 }

  # Presence of an archived milestone target should not alter results.
  let!(:archived_team_target) { create :target, :for_team, :archived, target_group: milestone_targets }

  describe '#eligibility' do
    context 'when the course has progression limited to one level' do
      context 'when startup has submitted all milestone targets' do
        before do
          complete_target team_target, student

          # Not all non-milestone targets need to be submitted.
          submit_target non_milestone_team_target, student
        end

        context 'when the next level is open' do
          it "returns 'Eligible'" do
            expect(subject.eligibility).to eq('Eligible')
          end
        end

        context 'when the next level is locked' do
          before do
            level_2.update!(unlock_at: 5.days.from_now)
          end

          it "returns 'DateLocked'" do
            expect(subject.eligibility).to eq('DateLocked')
          end

          after do
            level_2.update!(unlock_at: 5.days.ago)
          end
        end
      end

      context 'when there is a target that must be submitted individually by all students' do
        let!(:individual_target) { create :target, :for_founders, target_group: milestone_targets }

        before do
          submit_target non_milestone_team_target, student
          submit_target team_target, student
        end

        context 'when only one student has submitted the individual target' do
          before do
            # Only one student has submitted the individual target.
            submit_target individual_target, student
          end

          it "returns 'TeamMembersPending'" do
            expect(subject.eligibility).to eq('TeamMembersPending')
          end
        end

        context 'when all students have submitted work on the individual target' do
          before do
            # Each student should submit on their own.
            students.each { |s| submit_target individual_target, s }
          end

          it "returns 'Eligible'" do
            expect(subject.eligibility).to eq('Eligible')
          end
        end
      end

      context 'when milestone targets are incomplete' do
        it "returns 'CurrentLevelIncomplete'" do
          submit_target non_milestone_team_target, student

          expect(subject.eligibility).to eq('CurrentLevelIncomplete')
        end
      end

      context 'where there are no milestone target groups' do
        let!(:milestone_targets) { create :target_group, level: level_1, milestone: false }

        it "returns 'NoMilestonesInLevel'" do
          expect(subject.eligibility).to eq('NoMilestonesInLevel')
        end
      end

      context 'when there are more than one milestone target groups' do
        let!(:milestone_team_target_g2) { create :target, :for_team, :with_group, level: level_1, milestone: true }

        before do
          # Submit all targets in the first milestone target group.
          submit_target team_target, student
        end

        context 'when the second milestone target group contains incomplete targets' do
          it "returns 'CurrentLevelIncomplete'" do
            expect(subject.eligibility).to eq('CurrentLevelIncomplete')
          end
        end

        context 'when the second milestone target group has also been fully completed' do
          before do
            # Submit target in the second milestone group.
            submit_target milestone_team_target_g2, student
          end

          it "returns 'Eligible'" do
            expect(subject.eligibility).to eq('Eligible')
          end
        end
      end

      context 'when team is in the second level' do
        let(:startup) { create :startup, level: level_2 }
        let!(:milestone_target_l2) { create :target, :with_group, level: level_2, milestone: true, role: Target::ROLE_TEAM }
        let!(:level_3) { create :level, :three, course: course_1 }
        let!(:team_target) { create :target, :for_team, target_group: milestone_targets, evaluation_criteria: [evaluation_criterion] }

        before do
          complete_target milestone_target_l2, student
        end

        context "when student has a submission pending review in level 1" do
          before do
            submit_target team_target, student
          end

          it "returns 'PreviousLevelIncomplete'" do
            expect(subject.eligibility).to eq('PreviousLevelIncomplete')
          end
        end

        context 'when student has a failed submission in level 1' do
          before do
            submit_target team_target, student, grade: SubmissionsHelper::GRADE_FAIL
          end

          it "returns 'PreviousLevelIncomplete'" do
            expect(subject.eligibility).to eq('PreviousLevelIncomplete')
          end
        end

        context 'when there is a target in L1 that must be submitted individually by all students' do
          let!(:individual_target) { create :target, :for_founders, target_group: milestone_targets, evaluation_criteria: [evaluation_criterion] }

          before do
            complete_target team_target, student
            complete_target individual_target, student
          end

          context 'when student has team-mates with a pending review in level 1' do
            before do
              startup.founders.where.not(id: student).each do |other_student|
                submit_target individual_target, other_student
              end
            end

            it "returns 'TeamMembersPending'" do
              expect(subject.eligibility).to eq('TeamMembersPending')
            end
          end

          context 'when student has a team-mate with a failed submission in level 1' do
            before do
              startup.founders.where.not(id: student).each do |other_student|
                submit_target individual_target, other_student, grade: SubmissionsHelper::GRADE_FAIL
              end
            end

            it "returns 'TeamMembersPending'" do
              expect(subject.eligibility).to eq('TeamMembersPending')
            end
          end

          context "when student's team-mates have completed the target in level 1" do
            before do
              startup.founders.where.not(id: student).each do |other_student|
                complete_target individual_target, other_student
              end
            end

            it "returns 'Eligible'" do
              expect(subject.eligibility).to eq('Eligible')
            end
          end
        end
      end
    end

    context 'when the course has progression limited to three levels' do
      let(:course_1) { create :course, progression_limit: 3 }
      let(:level_3) { create :level, :three, course: course_1 }
      let!(:level_4) { create :level, :four, course: course_1 }
      let(:team_target) { create :target, :for_team, target_group: milestone_targets, evaluation_criteria: [evaluation_criterion] }
      let(:milestone_target_l2) { create :target, :team, :with_group, milestone: true, level: level_2, evaluation_criteria: [evaluation_criterion] }
      let(:milestone_target_l3) { create :target, :team, :with_group, milestone: true, level: level_3, evaluation_criteria: [evaluation_criterion] }

      context 'when team is in the third level and all milestone targets have been submitted' do
        let(:startup) { create :startup, level: level_3 }

        before do
          submit_target team_target, student
          submit_target milestone_target_l2, student
          submit_target milestone_target_l3, student
        end

        it "returns 'Eligible'" do
          expect(subject.eligibility).to eq('Eligible')
        end
      end

      context 'when team is in the fourth level and all milestone targets have been submitted' do
        let(:startup) { create :startup, level: level_4 }
        let(:milestone_target_l4) { create :target, :team, :with_group, milestone: true, level: level_4, evaluation_criteria: [evaluation_criterion] }

        before do
          submit_target team_target, student
          submit_target milestone_target_l2, student
          submit_target milestone_target_l3, student
          submit_target milestone_target_l4, student
        end

        it "returns 'AtMaxLevel'" do
          expect(subject.eligibility).to eq('AtMaxLevel')
        end
      end
    end

    context 'when the course has unlimited progression and team is in fourth level with all milestone targets submitted' do
      let(:course_1) { create :course, :unlimited }
      let(:level_3) { create :level, :three, course: course_1 }
      let(:level_4) { create :level, :four, course: course_1 }
      let!(:level_5) { create :level, :five, course: course_1 }
      let(:startup) { create :startup, level: level_4 }
      let(:team_target) { create :target, :for_team, target_group: milestone_targets, evaluation_criteria: [evaluation_criterion] }
      let(:milestone_target_l2) { create :target, :team, :with_group, milestone: true, level: level_2, evaluation_criteria: [evaluation_criterion] }
      let(:milestone_target_l3) { create :target, :team, :with_group, milestone: true, level: level_3, evaluation_criteria: [evaluation_criterion] }
      let(:milestone_target_l4) { create :target, :team, :with_group, milestone: true, level: level_4, evaluation_criteria: [evaluation_criterion] }

      before do
        submit_target team_target, student
        submit_target milestone_target_l2, student
        submit_target milestone_target_l3, student
        submit_target milestone_target_l4, student
      end

      it "returns 'Eligible'" do
        expect(subject.eligibility).to eq('Eligible')
      end
    end

    context 'when the course has strict progression' do
      let(:course_1) { create :course, :strict }
      let(:team_target) { create :target, :for_team, target_group: milestone_targets, evaluation_criteria: [evaluation_criterion] }

      context 'when the student has submitted all milestone targets' do
        before do
          submit_target team_target, student
          submit_target non_milestone_team_target, student
        end

        it "returns 'CurrentLevelIncomplete'" do
          expect(subject.eligibility).to eq('CurrentLevelIncomplete')
        end
      end

      context 'when the student has failed a milestone target' do
        before do
          fail_target team_target, student
        end

        it "returns 'CurrentLevelIncomplete'" do
          expect(subject.eligibility).to eq('CurrentLevelIncomplete')
        end
      end

      context 'when the student has passed all milestone targets' do
        before do
          complete_target team_target, student
        end

        it "returns 'Eligible'" do
          expect(subject.eligibility).to eq('Eligible')
        end
      end
    end
  end

  describe '#eligible?' do
    context 'when eligibility is "Eligible"' do
      it 'returns true' do
        allow(subject).to receive(:eligibility).and_return('Eligible')
        expect(subject.eligible?).to eq(true)
      end
    end

    context 'when eligibility is not "Eligible"' do
      it 'returns false' do
        %w[AtMaxLevel NoMilestonesInLevel CurrentLevelIncomplete PreviousLevelIncomplete TeamMembersPending DateLocked].each do |ineligible_marker|
          allow(subject).to receive(:eligibility).and_return(ineligible_marker)
          expect(subject.eligible?).to eq(false)
        end
      end
    end
  end
end
