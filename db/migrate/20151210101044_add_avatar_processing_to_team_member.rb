class AddAvatarProcessingToTeamMember < ActiveRecord::Migration[4.2]
  def change
    add_column :team_members, :avatar_processing, :boolean, default: false
  end
end
