require "rails_helper"
include RoutesResolvable

describe Notifications::ResolvePathService do
  subject { described_class.new(notification) }

  describe "#resolve" do
    context "when its a topic created notification" do
      let(:topic) { create :topic }
      let!(:notification) do
        create :notification,
               event: Notification.events[:topic_created],
               notifiable: topic
      end

      it "resolves topic path" do
        path = subject.resolve
        expect(path).to eq(url_helpers.topic_path(topic))
      end
    end

    context "when its a post created notification" do
      let(:topic) { create :topic, :with_first_post }
      let!(:notification) do
        create :notification,
               event: Notification.events[:post_created],
               notifiable: topic.posts.first
      end

      it "resolves topic path" do
        path = subject.resolve
        expect(path).to eq(url_helpers.topic_path(topic))
      end
    end

    context "When its a submission comment created notification" do
      let(:submission_comment) { create :submission_comment }
      let!(:notification) do
        create :notification,
               event: Notification.events[:submission_comment_created],
               notifiable: submission_comment
      end

      it "resolves target path" do
        path = subject.resolve
        expect(path).to eq(
          url_helpers.target_path(
            submission_comment.submission.target,
            {
              comment_id: submission_comment.id,
              submission_id: submission_comment.submission_id
            }
          )
        )
      end
    end

    context "When its a reaction created notification" do
      context "When its a reaction on a submission" do
        let(:reaction) { create :reaction }
        let!(:notification) do
          create :notification,
                 event: Notification.events[:reaction_created],
                 notifiable: reaction
        end

        it "resolves target path" do
          path = subject.resolve
          expect(path).to eq(
            url_helpers.target_path(
              reaction.reactionable.target,
              { submission_id: reaction.reactionable_id }
            )
          )
        end
      end
    end
  end
end
