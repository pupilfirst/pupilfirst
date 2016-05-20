class RenameApplicationStageScoreToApplicationSubmission < ActiveRecord::Migration
  def change
    rename_table :application_stage_scores, :application_submissions
  end
end
