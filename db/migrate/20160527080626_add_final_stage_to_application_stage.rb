class AddFinalStageToApplicationStage < ActiveRecord::Migration
  def change
    add_column :application_stages, :final_stage, :boolean
  end
end
