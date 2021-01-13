class AddCollegeToBatchApplicant < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applicants, :college, :string
  end
end
