require "rails_helper"

describe Discord::CommunityMessageService do
  subject { described_class }

  let(:discord_configuration) do
    {
      discord: {
        bot_token: "bot_token",
        server_id: "server_id",
        bot_user_id: "bot_user_id"
      }
    }
  end

  let(:school) do
    create :school, :current, configuration: discord_configuration
  end
  let(:community) do
    create :community, school: school, discord_channel_id: "channel_id"
  end
  let(:user) { create :user, school: school }
  let!(:topic) { create :topic, community: community, creator: user }

  describe "#post_topic_created" do
    it "posts a message" do
      message =
        I18n.t(
          "services.discord.community_message_service.post_topic_created",
          user_name: user.name,
          topic_url:
            "https://#{school.domains.primary.fqdn}/topics/#{topic.id}",
          topic_title: topic.title
        )

      expect(Discordrb::API::Channel).to receive(:create_message).with(
        "Bot #{discord_configuration[:discord][:bot_token]}",
        "channel_id",
        message
      )

      subject.new(community).post_topic_created(topic)
    end

    context "when the community does not have a discord channel id" do
      before { community.update(discord_channel_id: nil) }
      it "does not post a message" do
        expect(Discordrb::API::Channel).not_to receive(:create_message)

        subject.new(community).post_topic_created(topic)
      end
    end
  end
end
