require "rails_helper"

feature "Users Sync Roles", js: true do
  include UserSpecHelper

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

  let(:school_admin) { create :school_admin, school: school }

  let(:discord_role1) { create :discord_role, school: school }
  let(:discord_role2) { create :discord_role, school: school }

  let(:user) do
    create :user,
           school: school,
           discord_user_id: Faker::Number.number(digits: 10).to_s,
           discord_roles: [discord_role1, discord_role2]
  end

  let(:rest_client_double) { instance_double(RestClient::Response) }

  context "when school has discord configured and user has connected discord profile " do
    before do
      sign_in_user school_admin.user, referrer: school_user_path(user)
      user.update!(discord_roles: [discord_role1, discord_role2])
    end

    scenario "discord api reports same roles as user has" do
      stub = stub_request(
        :patch,
        "https://discord.com/api/v9/guilds/server_id/members/#{user.discord_user_id}"
      ).with(
        body: {roles: [discord_role1.discord_id, discord_role2.discord_id], nick: user.name}.to_json,
      ).to_return(
        status: 200,
        body: {
          roles: [discord_role1.discord_id, discord_role2.discord_id]
        }.to_json,
        headers: {}
      )

      click_link "Sync roles"

      expect(stub).to have_been_requested.once
      expect(user.discord_role_ids).to match_array([discord_role1.id, discord_role2.id])
    end
  end
end
