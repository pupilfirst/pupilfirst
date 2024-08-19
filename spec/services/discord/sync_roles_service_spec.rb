require "rails_helper"

describe Discord::SyncRolesService do
  subject { described_class }

  let(:discord_configuration) do
    {
      discord: {
        bot_token: "bot_token",
        server_id: "server_id",
        default_role_ids: ["default_role"],
        bot_user_id: "bot_user_id"
      }
    }
  end

  let(:school) { create :school, configuration: discord_configuration }

  let(:server_roles_response) do
    [
      (build :discord_server_role_response, position: 1),
      (build :discord_server_role_response, position: 2),
      (build :discord_server_role_response, position: 4)
    ]
  end

  let(:bot_user_roles_response) do
    {
      roles: [
        server_roles_response.first["id"],
        server_roles_response.second["id"]
      ]
    }
  end

  let(:roles_request) { instance_double(RestClient::Response) }
  let(:member_request) { instance_double(RestClient::Response) }

  describe "#save" do
    context "when discord is configured" do
      it "should fetch and cache the server roles" do
        expect(roles_request).to receive(:code).and_return(200)
        expect(member_request).to receive(:code).and_return(200)

        expect(roles_request).to receive(:body).and_return(
          server_roles_response.to_json
        )
        expect(member_request).to receive(:body).and_return(
          bot_user_roles_response.to_json
        )

        expect(Discordrb::API::Server).to receive(:roles).and_return(
          roles_request
        )

        expect(Discordrb::API::Server).to receive(:resolve_member).and_return(
          member_request
        )

        expect { subject.new(school: school).save }.to change {
          DiscordRole.count
        }.by(1)

        expect(DiscordRole.last.discord_id).to eq(
          server_roles_response.first["id"]
        )
      end
    end

    context "when discord is not configured" do
      before { school.update! configuration: {} }
      it "should raise SyncError" do
        expect(Discordrb::API::Server).to_not receive(:roles)

        expect { subject.new(school: school).save }.to raise_error(
          Discord::SyncRolesService::SyncError,
          "Please recheck Discord configuration values, Discord configuration is not configured."
        )
        expect(DiscordRole.count).to eq(0)
      end
    end
  end
end
