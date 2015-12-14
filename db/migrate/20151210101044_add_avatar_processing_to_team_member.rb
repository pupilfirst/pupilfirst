class AddAvatarProcessingToTeamMember < ActiveRecord::Migration
  def change
    add_column :team_members, :avatar_processing, :boolean, default: false
  end
end
