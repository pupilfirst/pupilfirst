require "rails_helper"

describe Notifications::CreateJob do
  subject { described_class.new(event, actor, resource) }

  describe "#perform" do
    context "when the event is post_created" do
      let(:event) { :post_created }
      let(:coach) { create :faculty }
      let(:topic) { create :topic }
      let(:resource) { create :post, topic: topic }
      let(:actor) { resource.creator }

      before { create :topic_subscription, topic: topic, user: coach.user }

      it "will create notification for post's topic's subscribers" do
        expect { subject.perform_now }.to change { Notification.count }.by(1)

        notification = Notification.last

        expect(notification.actor).to eq(resource.creator)
        expect(notification.notifiable_type).to eq("Post")
        expect(notification.notifiable_id).to eq(resource.id)
        expect(notification.read_at).to eq(nil)
        expect(notification.event).to eq("post_created")
        expect(notification.message).to eq(
          "#{resource.creator.name} has responded to a thread you are part of in the #{topic.community.name} community"
        )
        expect(notification.recipient).to eq(coach.user)
      end

      context "when the post has been archived" do
        let(:resource) { create :post, :archived, topic: topic }

        it "will skip" do
          expect { subject.perform_now }.not_to(change { Notification.count })
        end
      end
    end

    context "when the event is topic_created" do
      let(:event) { :topic_created }
      let(:resource) { create :topic, :with_first_post }
      let(:coach) { create :faculty }
      let(:actor) { resource.creator }

      before { create :topic_subscription, topic: resource, user: coach.user }

      it "will create notification for topic's subscribers" do
        expect { subject.perform_now }.to change { Notification.count }.by(1)

        notification = Notification.last

        expect(notification.actor).to eq(resource.creator)
        expect(notification.notifiable_type).to eq("Topic")
        expect(notification.notifiable_id).to eq(resource.id)
        expect(notification.read_at).to eq(nil)
        expect(notification.event).to eq("topic_created")
        expect(notification.message).to eq(
          "#{resource.creator.name} has created a new topic in #{resource.community.name} community"
        )
        expect(notification.recipient).to eq(coach.user)
      end
    end

    shared_context "discussion assignment setup" do
      let(:school) { create :school }
      let(:course) { create :course, school: school }
      let(:cohort) { create :cohort, course: course }
      let(:level) { create :level, course: course }
      let(:target_group) { create :target_group, level: level }
      let(:student) { create :student, cohort: cohort }
      let(:coach) { create :faculty }
      let(:assignment) do
        create :assignment, :with_default_checklist, discussion: true
      end
      let(:submission) do
        create :timeline_event,
               :with_owners,
               target: assignment.target,
               passed_at: 1.day.ago,
               owners: [student]
      end
      let(:actor) { resource.user }
    end

    context "When the event is submission_comment_created" do
      include_context "discussion assignment setup"

      let(:event) { :submission_comment_created }
      let(:resource) do
        create :submission_comment, submission: submission, user: coach.user
      end

      it "will create notification for students of the submission" do
        expect { subject.perform_now }.to change { Notification.count }.by(1)

        notification = Notification.last
        expect(notification.actor).to eq(resource.user)
        expect(notification.notifiable_type).to eq("SubmissionComment")
        expect(notification.notifiable_id).to eq(resource.id)
        expect(notification.read_at).to eq(nil)
        expect(notification.event).to eq("submission_comment_created")
        expect(notification.message).to eq(
          "#{resource.user.name} has commented on your submission for #{submission.target.title} target assignment"
        )
        expect(notification.recipient).to eq(student.user)
      end
    end

    context "when the event is reaction_created" do
      include_context "discussion assignment setup"

      let(:event) { :reaction_created }

      context "when the reaction is on a submission" do
        let(:resource) do
          create :reaction, reactionable: submission, user: coach.user
        end

        it "will create notification for students of the submission" do
          expect { subject.perform_now }.to change { Notification.count }.by(1)

          notification = Notification.last
          expect(notification.actor).to eq(resource.user)
          expect(notification.notifiable_type).to eq("Reaction")
          expect(notification.notifiable_id).to eq(resource.id)
          expect(notification.read_at).to eq(nil)
          expect(notification.event).to eq("reaction_created")
          expect(notification.message).to eq(
            "#{resource.user.name} has reacted #{resource.reaction_value} to your submission for #{submission.target.title} target assignment"
          )
          expect(notification.recipient).to eq(student.user)
        end
      end
    end
  end
end
