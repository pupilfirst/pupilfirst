class AddDiscordAccountRequiredToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :discord_account_required, :boolean, default: false
  end
end
