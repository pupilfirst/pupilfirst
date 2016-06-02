class RemoveBatchApplicationIdAndTeamLeadFromBatchApplicant < ActiveRecord::Migration
  def change
    remove_reference :batch_applicants, :batch_application
    remove_column :batch_applicants, :team_lead, :boolean
  end
end
