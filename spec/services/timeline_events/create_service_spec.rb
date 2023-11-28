require "rails_helper"

describe TimelineEvents::CreateService do
  subject { described_class.new(params, student) }

  let(:student) { create :student }
  let(:level) { create :level }
  let(:target_group) { create :target_group, level: level }
  let(:target) do
    create :target,
           :with_shared_assignment,
           given_role: Assignment::ROLE_STUDENT,
           target_group: target_group
  end
  let(:links) { [Faker::Internet.url, Faker::Internet.url] }
  let(:description) { Faker::Lorem.sentence }
  let(:checklist) do
    [
      {
        "title" => "File",
        "result" => "",
        "kind" => "files",
        "status" => "noAnswer"
      },
      {
        "title" => "Description",
        "result" => description,
        "kind" => "longText",
        "status" => "noAnswer"
      }
    ]
  end

  let(:params) { { target: target, checklist: checklist } }

  describe "#execute" do
    it "creates a new submission with the given params as the latest submission" do
      expect { subject.execute }.to change { TimelineEvent.count }.by(1)

      last_submission = TimelineEvent.last

      expect(last_submission.target).to eq(target)
      expect(last_submission.students.pluck(:id)).to eq([student.id])
      expect(last_submission.checklist).to eq(checklist)
      expect(last_submission.timeline_event_owners.pluck(:latest).uniq).to eq(
        [true]
      )
    end

    it "publishes submission_created event" do
      notification_service = instance_double("Developers::NotificationService")
      expect(notification_service).to receive(:execute).with(
        student.course,
        :submission_created,
        student.user,
        an_instance_of(TimelineEvent)
      )
      subject =
        described_class.new(
          params,
          student,
          notification_service: notification_service
        )
      subject.execute
    end

    context "when target is a team target and student is in a team" do
      let(:team) { create :team_with_students }
      let(:student) { team.students.first }
      let(:target) do
        create :target,
               :with_shared_assignment,
               given_role: Assignment::ROLE_TEAM,
               target_group: target_group
      end

      it "creates submission linked to all students in team" do
        subject.execute

        last_submission = TimelineEvent.last

        expect(last_submission.students.count).to eq(2)
        expect(last_submission.students.pluck(:id)).to match_array(
          student.team.students.pluck(:id)
        )
      end
    end

    context "when previous submissions exist" do
      let(:another_team) { create :team_with_students }
      let(:another_student) { another_team.students.first }
      let!(:first_submission) do
        create :timeline_event,
               :with_owners,
               latest: true,
               owners: [student],
               target: target
      end
      let!(:last_submission) do
        create :timeline_event,
               :with_owners,
               latest: true,
               owners: [student],
               target: target
      end
      let!(:another_submission) do
        create :timeline_event,
               :with_owners,
               latest: true,
               owners: [student, another_student],
               target: target
      end

      it "removes the latest flag from previous latest submission of same set of students" do
        expect { subject.execute }.to change { TimelineEvent.count }.by(1)
        expect(
          TimelineEvent.last.timeline_event_owners.pluck(:latest).uniq
        ).to eq([true])
        expect(
          first_submission.reload.timeline_event_owners.pluck(:latest).uniq
        ).to eq([false])
        expect(
          last_submission.reload.timeline_event_owners.pluck(:latest).uniq
        ).to eq([false])

        expect(
          another_submission
            .reload
            .timeline_event_owners
            .where(student: student)
            .first
            .latest
        ).to eq(false)
        expect(
          another_submission
            .reload
            .timeline_event_owners
            .where(student: another_student)
            .first
            .latest
        ).to eq(true)
      end
    end

    context "when target is an individual target with submissions from team members" do
      let(:another_student) { create :student }
      let!(:student_first_submission) do
        create :timeline_event,
               :with_owners,
               latest: true,
               owners: [student],
               target: target
      end
      let!(:another_student_submission) do
        create :timeline_event,
               :with_owners,
               latest: true,
               owners: [another_student],
               target: target
      end

      it "updates the latest flag only for submission from the student, not his team members" do
        subject.execute

        last_submission = TimelineEvent.last

        expect(
          last_submission
            .timeline_event_owners
            .where(student: student)
            .first
            .latest
        ).to eq(true)
        expect(
          student_first_submission
            .reload
            .timeline_event_owners
            .where(student: student)
            .first
            .latest
        ).to eq(false)
        expect(
          another_student_submission
            .reload
            .timeline_event_owners
            .where(student: another_student)
            .first
            .latest
        ).to eq(true)
      end
    end
  end
end
