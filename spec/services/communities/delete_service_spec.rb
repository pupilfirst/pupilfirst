require 'rails_helper'

describe Communities::DeleteService do
  subject { described_class.new(community_1) }

  let(:community_1) { create :community }
  let(:topic_c1) { create :topic, :with_first_post, community: community_1 }
  let!(:text_version_c1) { create :text_version, versionable: topic_c1.first_post }
  let!(:post_like_c1) { create :post_like, post: topic_c1.first_post }

  let(:community_2) { create :community }
  let(:topic_c2) { create :topic, :with_first_post, community: community_2 }
  let!(:text_version_c2) { create :text_version, versionable: topic_c2.first_post }
  let!(:post_like_c2) { create :post_like, post: topic_c2.first_post }

  describe '#execute' do
    it 'deletes all data related to this community and the community itself' do
      expect { subject.execute }.to change { Community.count }.from(2).to(1)

      expect { community_1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { topic_c1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { text_version_c1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { post_like_c1.reload }.to raise_error(ActiveRecord::RecordNotFound)

      expect(community_2.reload).to eq(community_2)
      expect(topic_c2.reload).to eq(topic_c2)
      expect(text_version_c2.reload).to eq(text_version_c2)
      expect(post_like_c2.reload).to eq(post_like_c2)
    end
  end
end
