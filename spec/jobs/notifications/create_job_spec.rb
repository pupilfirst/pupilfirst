require 'rails_helper'

describe Notifications::CreateJob do
  subject { described_class.new(event, actor, resource) }

  describe '#perform' do
    context 'when the event is post_created' do
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
        expect(notification.notifiable_type).to eq('Post')
        expect(notification.notifiable_id).to eq(resource.id)
        expect(notification.read_at).to eq(nil)
        expect(notification.event).to eq('post_created')
        expect(notification.message).to eq(
          "#{resource.creator.name} has responded to a thread you are part of in the #{topic.community.name} community"
        )
        expect(notification.recipient).to eq(coach.user)
      end

      context 'when the post has been archived' do
        let(:resource) { create :post, :archived, topic: topic }

        it 'will skip' do
          expect { subject.perform_now }.not_to(change { Notification.count })
        end
      end
    end

    context 'when the event is topic_created' do
      let(:event) { :topic_created }
      let(:resource) { create :topic, :with_first_post }
      let(:coach) { create :faculty }
      let(:actor) { resource.creator }

      before { create :topic_subscription, topic: resource, user: coach.user }

      it "will create notification for topic's subscribers" do
        expect { subject.perform_now }.to change { Notification.count }.by(1)

        notification = Notification.last

        expect(notification.actor).to eq(resource.creator)
        expect(notification.notifiable_type).to eq('Topic')
        expect(notification.notifiable_id).to eq(resource.id)
        expect(notification.read_at).to eq(nil)
        expect(notification.event).to eq('topic_created')
        expect(notification.message).to eq(
          "#{resource.creator.name} has created a new topic in #{resource.community.name} community"
        )
        expect(notification.recipient).to eq(coach.user)
      end
    end
  end
end
