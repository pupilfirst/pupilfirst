require 'rails_helper'

describe Targets::StatusService do
  subject { described_class.new(founder_target_1, founder_1) }

  let(:course) { create :course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:startup) { create :startup, level: level_2 }
  let(:founder_1) { startup.founders.first }
  let!(:founder_2) { create :founder, startup: startup }
  let(:target_group) { create :target_group, level: level_2 }
  let(:founder_target_1) { create :target, target_group: target_group, role: Target::ROLE_STUDENT }

  describe '#status' do
    context 'when the target has no submissions' do
      context 'when the course is locked' do
        let(:course) { create :course, ends_at: 1.day.ago }

        it "returns :course_locked" do
          expect(subject.status).to eq(Targets::StatusService::STATUS_COURSE_LOCKED)
        end
      end

      context "when the student's access has ended" do
        let(:startup) { create :startup, level: level_2, access_ends_at: 1.day.ago }

        it "returns :access_locked" do
          expect(subject.status).to eq(Targets::StatusService::STATUS_ACCESS_LOCKED)
        end
      end

      context 'when the target is not locked for any reason' do
        it 'returns :pending' do
          expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
        end
      end

      context 'when the target is from a higher level than the startup' do
        let(:startup) { create :startup, level: level_1 }

        context 'when the target is reviewed by a coach' do
          let(:evaluation_criterion) { create :evaluation_criterion, course: course }

          before do
            founder_target_1.evaluation_criteria << evaluation_criterion
          end

          it 'returns :level_locked' do
            expect(subject.status).to eq(Targets::StatusService::STATUS_LEVEL_LOCKED)
          end
        end

        it 'returns :pending for auto-verified target' do
          expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
        end
      end

      context 'when the target has other prerequisite targets' do
        let(:team_target_1) { create :target, target_group: target_group, role: Target::ROLE_TEAM }
        let(:founder_target_2) { create :target, target_group: target_group, role: Target::ROLE_STUDENT }

        before do
          founder_target_1.prerequisite_targets << [team_target_1, founder_target_2]
        end

        context 'when any prerequisites is incomplete' do
          it 'returns :prerequisite_locked' do
            expect(subject.status).to eq(Targets::StatusService::STATUS_PREREQUISITE_LOCKED)
          end
        end

        context 'when prerequisites are a mix of draft and live targets' do
          let(:team_target_1) { create :target, :draft, target_group: target_group, role: Target::ROLE_TEAM }

          before do
            # Submit the individual target.
            create :timeline_event, :with_owners, latest: true, owners: [founder_1], target: founder_target_2, passed_at: 1.day.ago
          end

          it 'returns :pending' do
            expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
          end
        end

        context 'when all prerequisites are complete' do
          let!(:submission_1) do
            create :timeline_event, :with_owners, latest: true, owners: [founder_1, founder_2], target: team_target_1, passed_at: 1.day.ago
          end

          let!(:submission_2) do
            create :timeline_event, :with_owners, latest: true, owners: [founder_1], target: founder_target_2, passed_at: 1.day.ago
          end

          it 'returns :pending' do
            expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
          end
        end
      end
    end

    context 'when the target has a submission' do
      let!(:submission) { create :timeline_event, :with_owners, latest: true, owners: [founder_1], target: founder_target_1 }

      context 'when the submission is not evaluated yet' do
        it 'returns :submitted' do
          expect(subject.status).to eq(Targets::StatusService::STATUS_SUBMITTED)
        end
      end

      context 'when the submission has passed_at set' do
        let!(:submission) do
          create :timeline_event, :with_owners, latest: true, owners: [founder_1], target: founder_target_1, passed_at: 1.day.ago
        end

        it 'returns :passed' do
          expect(subject.status).to eq(Targets::StatusService::STATUS_PASSED)
        end
      end

      context 'when the submission was evaluated but passed_at not set' do
        let(:faculty) { create :faculty }
        let!(:submission) do
          create :timeline_event, :with_owners, :evaluated, latest: true, owners: [founder_1], target: founder_target_1
        end

        it 'returns :failed' do
          expect(subject.status).to eq(Targets::StatusService::STATUS_FAILED)
        end
      end
    end
  end
end
