require "rails_helper"

describe TimelineEvents::WasLastTargetService do
  include SubmissionsHelper

  let(:school) { create :school, :current }
  let(:course) { create :course, :with_cohort, school: school }
  let(:cohort) { course.cohorts.first }
  let(:level) { create :level, :one, course: course }
  let(:target_group) { create :target_group, level: level }
  let!(:team) { create :team_with_students, cohort: cohort }
  let(:student) { team.students.first }

  let(:individual_target) { create :target, target_group: target_group }
  let!(:individual_assignment) do
    create :assignment,
           :with_default_checklist,
           :with_evaluation_criterion,
           role: Assignment::ROLE_STUDENT,
           target: individual_target,
           milestone_number: 1,
           milestone: true
  end

  let(:team_target) { create :target, target_group: target_group }
  let!(:team_assignment) do
    create :assignment,
           :with_default_checklist,
           :with_evaluation_criterion,
           role: Assignment::ROLE_TEAM,
           target: team_target,
           milestone_number: 2,
           milestone: true
  end

  describe "#was_last_target?" do
    subject { described_class.new(submission) }

    context "when all assignments are completed by the student" do
      let(:submission) { complete_target(individual_target, student) }

      before do
        student.update(team_id: nil)
        complete_target(team_target, student)
      end

      it "returns true" do
        expect(subject.was_last_target?).to be true
      end

      it "returns false when a submission is archived" do
        submission.update!(archived_at: Time.zone.now)
        expect(subject.was_last_target?).to be false
      end
    end

    context "when assignments are completed by all team members" do
      let(:submission) { complete_target(team_target, student) }

      before do
        team.students.each { |s| complete_target(individual_target, s) }
      end

      it "returns true" do
        expect(subject.was_last_target?).to be true
      end
    end

    context "when assignments are completed only by some team members" do
      let(:submission) { complete_target(team_target, student) }

      it "returns false" do
        expect(subject.was_last_target?).to be false
      end
    end

    context "when there are no milestone assignments" do
      before do
        course.assignments.milestone.each { |a| a.update!(archived: true) }
      end

      let(:submission) { complete_target(team_target, student) }

      it "returns false" do
        expect(subject.was_last_target?).to be false
      end
    end

    context "when a target is archived but its milestone assignment is not" do
      let(:submission) { complete_target(individual_target, student) }

      before do
        create :target,
               :with_shared_assignment,
               target_group: target_group,
               visibility: Target::VISIBILITY_ARCHIVED,
               safe_to_change_visibility: true,
               given_milestone_number: 3

        student.update(team_id: nil)
        complete_target(team_target, student)
      end

      it "returns true" do
        expect(subject.was_last_target?).to be true
      end
    end
  end
end
