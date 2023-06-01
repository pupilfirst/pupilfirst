class AddGithubTeamIdToCourse < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :github_team_id, :integer
    add_column :founders, :github_repository, :string
  end
end
