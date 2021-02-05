require 'rails_helper'

describe Notifications::PostCreatedJob do
  subject { described_class.new(actor_id, post_id) }
  let(:topic) { create :topic }
  let(:post) { create :post, topic: topic }
  let(:coach) { create :faculty }
  let(:actor_id) { post.creator.id }
  let(:post_id) { post.id }

  describe '#perform' do
    before do
      create :topic_subscription, topic: topic, user: coach.user
    end

    context 'when job is scheduled with an invalid post id' do
      let(:post_id) { 'xxxx' }

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

    context 'with valid actor and post IDs' do
      let(:actor_id) { post.creator.id }
      let(:post_id) { post.id }

      it 'creates a notification' do
        subject.perform_now
        expect { subject.perform_now }.to change { Notification.count }.by(1)
        notification = Notification.last
        expect(notification.actor).to eq(post.creator)
        expect(notification.notifiable_type).to eq('Post')
        expect(notification.notifiable_id).to eq(post.id)
        expect(notification.read_at).to eq(nil)
        expect(notification.event).to eq('post_created')
        expect(notification.message).to eq("#{post.creator.name} has responded to a thread you are part of in the #{topic.community.name} community")
        expect(notification.recipient).to eq(coach.user)
      end
    end
  end
end
