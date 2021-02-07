require 'rails_helper'

describe Notifications::TopicCreatedJob do
  subject { described_class.new(actor_id, topic_id) }
  let(:topic) { create :topic, :with_first_post }
  let(:coach) { create :faculty }
  let(:actor_id) { topic.creator.id }
  let(:topic_id) { topic.id }

  describe '#perform' do
    before do
      create :topic_subscription, topic: topic, user: coach.user
    end

    describe 'job scheduled with an in-valid topic id' do
      let(:topic_id) { 'xxxx' }

      it 'will not create notifications' do
        subject.perform_now
        expect(Notification.count).to eq(0)
      end
    end

    describe 'Job scheduled with an in-valid actor id' do
      let(:actor_id) { 'xxxx' }

      it 'will not create notifications' do
        subject.perform_now
        expect(Notification.count).to eq(0)
      end
    end

    scenario 'creates notification' do
      subject.perform_now
      expect(Notification.count).to eq(1)
      notification = Notification.last
      expect(notification.actor).to eq(topic.creator)
      expect(notification.notifiable_type).to eq('Topic')
      expect(notification.notifiable_id).to eq(topic.id)
      expect(notification.read_at).to eq(nil)
      expect(notification.event).to eq('topic_created')
      expect(notification.message).to eq("#{topic.creator.name} has created a new topic in #{topic.community.name} community")
      expect(notification.recipient).to eq(coach.user)
    end
  end
end
