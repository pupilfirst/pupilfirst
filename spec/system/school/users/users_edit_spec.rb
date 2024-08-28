require "rails_helper"

feature "Users Edit", js: true do
  include UserSpecHelper
  include NotificationHelper

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
  let(:school_2) { create :school }

  let(:school_admin) { create :school_admin, school: school }

  let(:user) do
    create :user,
           school: school,
           discord_user_id: Faker::Number.number(digits: 10).to_s
  end
  let!(:school_2_user) { create :user, school: school_2 }

  let(:cohort) { create :cohort }
  let!(:student) { create :student, cohort: cohort, user: user }

  let(:rest_client_double) { instance_double(RestClient::Response) }

  around do |example|
    Time.use_zone(school_admin.user.time_zone) { example.run }
  end

  context "when school has discord configured and user has connected discord profile " do
    before do
      4.times { create :discord_role, school: school }
      cohort.update!(discord_role_ids: [DiscordRole.first.discord_id])
    end

    scenario "admins updates users discord roles" do
      sign_in_user school_admin.user, referrer: edit_school_user_path(user)

      expect(rest_client_double).to receive(:code).and_return(200)
      expect(rest_client_double).to receive(:body).and_return(
        {
          roles: [DiscordRole.first.discord_id, DiscordRole.last.discord_id]
        }.to_json
      )
      expect(Discordrb::API::Server).to receive(:update_member).with(
        "Bot #{discord_configuration[:discord][:bot_token]}",
        discord_configuration[:discord][:server_id],
        user.discord_user_id,
        roles: [DiscordRole.last.discord_id, DiscordRole.first.discord_id],
        nick: user.name
      ).and_return(rest_client_double)

      expect(page).to have_text("Fixed roles for #{user.name}")
      expect(page).to have_text(DiscordRole.first.name)

      click_button DiscordRole.last.name
      click_button "Update Discord Role"

      expect(page).to have_text("Successfully assigned the roles to user.")
    end
  end

  context "when schools discord is not configured" do
    before { school.update! configuration: {} }

    scenario "admin tries to update users discord roles" do
      sign_in_user school_admin.user, referrer: edit_school_user_path(user)

      click_button "Update Discord Role"

      expect(page).to have_text(
        "Please configure Discord integration before updating user roles."
      )
    end
  end

  context "when user has not linked discord profile" do
    before { user.update!(discord_user_id: nil) }

    scenario "admin tries to update users discord roles" do
      sign_in_user school_admin.user, referrer: edit_school_user_path(user)

      click_button "Update Discord Role"

      expect(page).to have_text(
        "The user does not have a connected Discord profile."
      )
    end
  end

  scenario "admin try to edit user of another school" do
    sign_in_user school_admin.user, referrer: edit_school_user_path(school_2_user)

    expect(page).to have_text("The page you were looking for doesn't exist!")
  end
end
