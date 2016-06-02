class RenameApplicationFounderToBatchApplicant < ActiveRecord::Migration
  def change
    rename_table :application_founders, :batch_applicants
  end
end
