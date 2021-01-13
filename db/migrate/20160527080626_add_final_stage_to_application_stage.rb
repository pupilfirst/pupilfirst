class AddFinalStageToApplicationStage < ActiveRecord::Migration[4.2]
  def change
    add_column :application_stages, :final_stage, :boolean
  end
end
