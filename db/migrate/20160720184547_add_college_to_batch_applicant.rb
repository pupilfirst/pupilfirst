class AddCollegeToBatchApplicant < ActiveRecord::Migration
  def change
    add_column :batch_applicants, :college, :string
  end
end
