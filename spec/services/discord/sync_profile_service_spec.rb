require "rails_helper"

describe Discord::SyncProfileService do
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

  let(:cohort_1) do
    create :cohort,
           school: school,
           discord_role_ids: %w[role_1 role_2 role_shared]
  end

  let(:cohort_2) do
    create :cohort, school: school, discord_role_ids: %w[role_3 role_4]
  end

  let(:cohort_3) do
    create :cohort, school: school, discord_role_ids: %w[another_role]
  end

  let!(:student_1) { create :student, user: user, cohort: cohort_1 }
  let!(:student_2) { create :student, user: user, cohort: cohort_2 }
  let!(:student_3) { create :student, cohort: cohort_3 }

  let(:rest_client_double) { instance_double(RestClient::Response) }

  describe "#execute" do
    context "when a user has a discord user id" do
      let!(:default_role) do
        create :discord_role,
               school: school,
               default: true,
               discord_id: "default_role"
      end

      it "resets the roles" do
        expect(rest_client_double).to receive(:code).and_return(200)
        expect(rest_client_double).to receive(:body).and_return(
          '{ "roles": ["role_1", "role_2", "role_shared", "default_role"] }'
        )

        expect(Discordrb::API::Server).to receive(:update_member).with(
          "Bot #{discord_configuration[:discord][:bot_token]}",
          discord_configuration[:discord][:server_id],
          user.discord_user_id,
          roles:
            a_collection_containing_exactly(
              "role_1",
              "role_2",
              "role_shared",
              "role_3",
              "role_4",
              "default_role"
            ),
          nick: user.name
        ).and_return(rest_client_double)

        expect { subject.new(user).execute }.to_not(
          change { AdditionalUserDiscordRole.count }
        )
      end
    end

    context "when a user does not have a discord user id" do
      before { user.update(discord_user_id: nil) }
      it "does not resets the roles" do
        expect(Discordrb::API::Server).not_to receive(:update_member)

        expect { subject.new(user).execute }.to raise_error(
          Discord::SyncProfileService::SyncError,
          "The user doesn't have Discord account connected."
        )
      end
    end

    context "when configuration is not present" do
      before { school.update!(configuration: {}) }
      it "raises SyncError" do
        expect(Discordrb::API::Server).not_to receive(:update_member)

        expect { subject.new(user).execute }.to raise_error(
          Discord::SyncProfileService::SyncError,
          "The Discord integration is not configured."
        )
      end
    end

    context "when user is assigned additional discord roles" do
      before do
        4.times { create :discord_role, school: school }
        DiscordRole.last.update(discord_id: "default_role", default: true)
      end

      let(:additional_discord_role_ids) { DiscordRole.limit(2).pluck(:id) }
      let(:roles_ids) do
        DiscordRole.where(id: additional_discord_role_ids).pluck(:discord_id)
      end

      it "syncs and links user to discord roles" do
        expect(rest_client_double).to receive(:code).and_return(200)
        expect(rest_client_double).to receive(:body).and_return(
          "{\"roles\": [\"role_1\", \"role_2\", \"role_shared\", \"default_role\", \"#{roles_ids.first}\", \"#{roles_ids.last}\"]}"
        )

        expect(Discordrb::API::Server).to receive(:update_member).with(
          "Bot #{discord_configuration[:discord][:bot_token]}",
          discord_configuration[:discord][:server_id],
          user.discord_user_id,
          roles:
            a_collection_containing_exactly(
              "role_1",
              "role_2",
              "role_shared",
              "role_3",
              "role_4",
              "default_role",
              roles_ids.first,
              roles_ids.last
            ),
          nick: user.name
        ).and_return(rest_client_double)

        subject.new(
          user,
          additional_discord_role_ids: additional_discord_role_ids
        ).execute

        expect(user.discord_roles.pluck(:discord_id)).to eq(
          [roles_ids.first, roles_ids.last]
        )
      end
    end
  end
end
