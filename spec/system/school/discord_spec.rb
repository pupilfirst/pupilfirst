require "rails_helper"

feature "School Discord Configuration", js: true do
  include UserSpecHelper
  include NotificationHelper

  let(:discord_configuration) do
    {
      "discord" => {
        "bot_token" => "bot_token.123456789.123456789",
        "server_id" => "123456789",
        "bot_user_id" => "123456789",
      }
    }
  end

  let!(:school) { create :school, :current }
  let!(:school_admin) { create :school_admin, school: school }

  let(:roles_request) { instance_double(RestClient::Response) }
  let(:member_request) { instance_double(RestClient::Response) }

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

  scenario "admin saves discord credentials" do
    sign_in_user school_admin.user, referrer: discord_configuration_school_path

    expect(page).to have_text("Not configured")
    expect(page).to_not have_button("Sync Roles")

    fill_in "server_id", with: discord_configuration.dig("discord", "server_id")
    fill_in "bot_user_id",
            with: discord_configuration.dig("discord", "bot_user_id")
    fill_in "bot_token", with: discord_configuration.dig("discord", "bot_token")

    click_button "Save credentials"

    expect(page).to have_text("Configured")

    expect(school.reload.configuration["discord"]).to eq(
      discord_configuration["discord"]
    )
  end

  scenario "admin syncs discord roles" do
    sign_in_user school_admin.user, referrer: discord_server_roles_school_path

    expect(page).to have_text("Discord integration is not configured")

    school.update!(configuration: discord_configuration)

    visit discord_server_roles_school_path

    expect(page).to have_text("No saved Discord roles were found")

    expect(roles_request).to receive(:code).and_return(200)
    expect(member_request).to receive(:code).and_return(200)

    expect(roles_request).to receive(:body).and_return(
      server_roles_response.to_json
    )
    expect(member_request).to receive(:body).and_return(
      bot_user_roles_response.to_json
    )

    expect(Discordrb::API::Server).to receive(:roles).and_return(roles_request)

    expect(Discordrb::API::Server).to receive(:resolve_member).and_return(
      member_request
    )

    click_button "Sync Roles"

    expect(page).to have_text(server_roles_response.first["name"])

    expect(page).to_not have_text(server_roles_response.second["name"])
    expect(page).to_not have_text(server_roles_response.last["name"])
  end

  context "when admin sets roles as defaults" do
    before { school.update! configuration: discord_configuration }
    let!(:discord_role_1) { create :discord_role, school: school }
    let!(:discord_role_2) { create :discord_role, school: school }

    scenario "admin sets roles as default roles" do
      sign_in_user school_admin.user, referrer: discord_server_roles_school_path

      expect(page).to have_text(discord_role_2.name)
      find("input[type='checkbox'][value='#{discord_role_1.id}'").click

      click_button "Update default roles"

      expect(page).to have_text("Successfully updated default Discord roles.")

      expect(discord_role_1.reload.default).to eq(true)
    end
  end

  context "when role is deleted on discord" do
    before { school.update! configuration: discord_configuration }
    let!(:deleted_role) { create :discord_role, school: school }

    scenario "admin reviews and syncs discord roles" do
      sign_in_user school_admin.user, referrer: discord_server_roles_school_path

      expect(page).to have_text(deleted_role.name)

      expect(roles_request).to receive(:code).and_return(200).at_least(:once)
      expect(member_request).to receive(:code).and_return(200).at_least(:once)

      expect(roles_request).to receive(:body).and_return(
        server_roles_response.to_json
      ).at_least(:once)

      expect(member_request).to receive(:body).and_return(
        bot_user_roles_response.to_json
      ).at_least(:once)

      expect(Discordrb::API::Server).to receive(:roles).and_return(
        roles_request
      ).at_least(:once)

      expect(Discordrb::API::Server).to receive(:resolve_member).and_return(
        member_request
      ).at_least(:once)

      expect(page).to have_text(deleted_role.name)

      click_button "Sync Roles"

      expect(page).to have_text(
        "Please confirm the action before saving the Discord server roles."
      )

      expect(school.discord_roles.count).to eq(1)

      click_button "Confirm Sync"

      expect(page).to_not have_text(deleted_role.name)
      expect(DiscordRole.find_by(id: deleted_role.id)).to eq(nil)

      expect(page).to have_text(server_roles_response.first["name"])
    end
  end
end
