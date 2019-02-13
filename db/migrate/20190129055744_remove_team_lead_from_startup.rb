class RemoveTeamLeadFromStartup < ActiveRecord::Migration[5.2]
  def change
    remove_reference :startups, :team_lead
  end
end
