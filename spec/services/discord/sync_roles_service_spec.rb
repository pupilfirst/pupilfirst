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
      {
        "id" => "#{Faker::Number.number(digits: 24)}",
        "icon" => nil,
        "name" => Faker::Name.name,
        "color" => 0,
        "flags" => 0,
        "hoist" => false,
        "managed" => true,
        "position" => 1,
        "description" => nil,
        "mentionable" => false,
        "permissions" => "8",
        "unicode_emoji" => nil
      },
      {
        "id" => "#{Faker::Number.number(digits: 24)}",
        "icon" => nil,
        "name" => Faker::Name.name,
        "color" => 0,
        "flags" => 0,
        "hoist" => false,
        "managed" => true,
        "position" => 2,
        "description" => nil,
        "mentionable" => false,
        "permissions" => "8",
        "unicode_emoji" => nil
      },
      {
        "id" => "#{Faker::Number.number(digits: 24)}",
        "icon" => nil,
        "name" => Faker::Name.name,
        "color" => 0,
        "flags" => 0,
        "hoist" => false,
        "managed" => true,
        "position" => 4,
        "description" => nil,
        "mentionable" => false,
        "permissions" => "8",
        "unicode_emoji" => nil
      }
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

  describe "#sync" do
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

        expect { subject.new(school: school).sync }.to change {
          DiscordRole.count
        }.by(1)

        expect(DiscordRole.last.discord_id).to eq(
          server_roles_response.first["id"]
        )
      end
    end

    context "when discord is not configured" do
      before { school.update! configuration: {} }
      it "should abort the sync operation" do
        expect(Discordrb::API::Server).to_not receive(:roles)

        expect(subject.new(school: school).sync).to eq(false)
        expect(DiscordRole.count).to eq(0)
      end
    end
  end
end
