require "rails_helper"

describe Discord::SyncNameService do
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

  let(:school) { create :school, configuration: discord_configuration }
  let!(:user) do
    create :user,
           school: school,
           name: Faker::Name.name,
           discord_user_id: Faker::Number.number(digits: 18)
  end

  describe "#execute" do
    context "when a user has a discord user id" do
      it "syncs the name" do
        expect(Discordrb::API::Server).to receive(:update_member).with(
          "Bot #{discord_configuration[:discord][:bot_token]}",
          discord_configuration[:discord][:server_id],
          user.discord_user_id,
          nick: user.name
        )

        subject.new(user).execute
      end
    end

    context "when a user does not have a discord user id" do
      before { user.update(discord_user_id: nil) }
      it "does not sync the name" do
        expect(Discordrb::API::Server).not_to receive(:update_member)

        subject.new(user).execute
      end
    end

    context "when configuration is not present" do
      before { school.update!(configuration: {}) }
      it "does not sync the name" do
        expect(Discordrb::API::Server).not_to receive(:update_member)

        subject.new(user).execute
      end
    end
  end
end
