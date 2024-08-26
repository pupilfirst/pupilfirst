require "rails_helper"

describe Discord::ClearRolesService do
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

  let(:user) do
    create :user,
           school: school,
           discord_user_id: Faker::Number.number(digits: 18)
  end

  describe "#execute" do
    context "when a user has a discord user id" do
      it "clears the roles" do
        expect(Discordrb::API::Server).to receive(:update_member).with(
          "Bot #{discord_configuration[:discord][:bot_token]}",
          discord_configuration[:discord][:server_id],
          user.discord_user_id,
          roles: []
        )

        subject.new(
          user.discord_user_id,
          Schools::Configuration::Discord.new(school)
        ).execute
      end
    end

    context "when configuration is not present" do
      before { school.update!(configuration: {}) }
      it "does not clear the roles" do
        expect(Discordrb::API::Server).not_to receive(:update_member)

        subject.new(
          user.discord_user_id,
          Schools::Configuration::Discord.new(school)
        ).execute
      end
    end
  end
end
