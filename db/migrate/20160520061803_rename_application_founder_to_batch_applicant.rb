class RenameApplicationFounderToBatchApplicant < ActiveRecord::Migration[4.2]
  def change
    rename_table :application_founders, :batch_applicants
  end
end
