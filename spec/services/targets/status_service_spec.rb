require "rails_helper"

describe Targets::StatusService do
  subject { described_class.new(student_target_1, student_1) }

  let(:course) { create :course }
  let(:cohort) { create :cohort, course: course }
  let(:level_1) { create :level, :one, course: course }
  let(:level_2) { create :level, :two, course: course }
  let(:team) { create :team, cohort: cohort }
  let(:student_1) { create :student, cohort: cohort, team: team }
  let(:student_2) { create :student, cohort: cohort, team: team }
  let(:target_group) { create :target_group, level: level_2 }
  let(:student_target_1) do
    create :target,
           :with_shared_assignment,
           target_group: target_group,
           given_role: Assignment::ROLE_STUDENT
  end

  describe "#status" do
    context "when the target has no submissions" do
      context "when the course is locked" do
        let(:cohort) { create :cohort, ends_at: 1.day.ago, course: course }

        it "returns :course_locked" do
          expect(subject.status).to eq(
            Targets::StatusService::STATUS_COURSE_LOCKED
          )
        end
      end

      context "when the student's access has ended" do
        let!(:cohort) { create :cohort, ends_at: 1.day.ago, course: course }
        let!(:another_cohort) { create :cohort, course: course }

        it "returns :access_locked" do
          expect(subject.status).to eq(
            Targets::StatusService::STATUS_ACCESS_LOCKED
          )
        end
      end

      context "when the target is not locked for any reason" do
        it "returns :pending" do
          expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
        end
      end

      context "when the target is from a higher level than the team" do
        let!(:student_1) { create :student, team: team }

        it "returns :pending for auto-verified target" do
          expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
        end
      end

      context "when the target has other prerequisite targets" do
        let(:team_target_1) do
          create :target,
                 :with_shared_assignment,
                 target_group: target_group,
                 given_role: Assignment::ROLE_TEAM
        end
        let(:student_target_2) do
          create :target,
                 :with_shared_assignment,
                 target_group: target_group,
                 given_role: Assignment::ROLE_STUDENT
        end

        before do
          student_target_1.assignments.first.prerequisite_assignments << [
            team_target_1.assignments.first,
            student_target_2.assignments.first
          ]
        end

        context "when any prerequisites is incomplete" do
          it "returns :prerequisite_locked" do
            expect(subject.status).to eq(
              Targets::StatusService::STATUS_PREREQUISITE_LOCKED
            )
          end
        end

        context "when prerequisites are a mix of draft and live targets" do
          let(:team_target_1) do
            create :target,
                   :draft,
                   :with_shared_assignment,
                   target_group: target_group,
                   given_role: Assignment::ROLE_TEAM
          end

          before do
            # Submit the individual target.
            create :timeline_event,
                   :with_owners,
                   latest: true,
                   owners: [student_1],
                   target: student_target_2,
                   passed_at: 1.day.ago
          end

          it "returns :pending" do
            expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
          end
        end

        context "when all prerequisites are complete" do
          let!(:submission_1) do
            create :timeline_event,
                   :with_owners,
                   latest: true,
                   owners: [student_1, student_2],
                   target: team_target_1,
                   passed_at: 1.day.ago
          end

          let!(:submission_archived) do
            create :timeline_event,
                   :with_owners,
                   latest: true,
                   archived_at: 1.day.ago,
                   owners: [student_1, student_2],
                   target: team_target_1,
                   passed_at: 1.day.ago
          end

          let!(:submission_2) do
            create :timeline_event,
                   :with_owners,
                   latest: true,
                   owners: [student_1],
                   target: student_target_2,
                   passed_at: 1.day.ago
          end

          it "returns :pending" do
            expect(subject.status).to eq(Targets::StatusService::STATUS_PENDING)
          end
        end
      end
    end

    context "when the target has a submission" do
      let!(:submission) do
        create :timeline_event,
               :with_owners,
               latest: true,
               owners: [student_1],
               target: student_target_1
      end

      context "when the submission is not evaluated yet" do
        it "returns :submitted" do
          expect(subject.status).to eq(Targets::StatusService::STATUS_SUBMITTED)
        end
      end

      context "when the submission has passed_at set" do
        let!(:submission) do
          create :timeline_event,
                 :with_owners,
                 latest: true,
                 owners: [student_1],
                 target: student_target_1,
                 passed_at: 1.day.ago
        end

        it "returns :passed" do
          expect(subject.status).to eq(Targets::StatusService::STATUS_PASSED)
        end
      end

      context "when the submission was evaluated but passed_at not set" do
        let(:faculty) { create :faculty }
        let!(:submission) do
          create :timeline_event,
                 :with_owners,
                 :evaluated,
                 latest: true,
                 owners: [student_1],
                 target: student_target_1
        end

        it "returns :failed" do
          expect(subject.status).to eq(Targets::StatusService::STATUS_FAILED)
        end
      end
    end
  end
end
