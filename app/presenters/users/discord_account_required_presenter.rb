module Users
  class DiscordAccountRequiredPresenter < EditPresenter
    def image_path
      prefix =
        current_user.discord_account_connected? ? "connected" : "disconnected"

      suffix = current_school.name.include?("Pupilfirst") ? "pf" : "school"
      view.image_path("users/discord_account_required/#{prefix}_#{suffix}.svg")
    end
  end
end
