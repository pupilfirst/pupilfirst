class RenameApplicationStageScoreToApplicationSubmission < ActiveRecord::Migration[4.2]
  def change
    rename_table :application_stage_scores, :application_submissions
  end
end
