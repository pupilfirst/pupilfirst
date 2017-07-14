class AddAdmissionStageToStartup < ActiveRecord::Migration[5.1]
  def change
    add_column :startups, :admission_stage, :string
  end
end
