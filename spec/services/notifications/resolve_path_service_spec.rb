require 'rails_helper'
include RoutesResolvable

describe Notifications::ResolvePathService do
  subject { described_class.new(notification) }

  describe '#resolve' do
    context 'when its a topic created notification' do
      let(:topic) { create :topic }
      let!(:notification) { create :notification, event: Notification.events[:topic_created], notifiable: topic }

      it 'resolves topic path' do
        path = subject.resolve
        expect(path).to eq(url_helpers.topic_path(topic))
      end
    end

    context 'when its a post created notification' do
      let(:topic) { create :topic, :with_first_post }
      let!(:notification) { create :notification, event: Notification.events[:post_created], notifiable: topic.posts.first }

      it 'resolves topic path' do
        path = subject.resolve
        expect(path).to eq(url_helpers.topic_path(topic))
      end
    end
  end
end
