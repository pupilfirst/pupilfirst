class AddReferenceToBatchApplicant < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applicants, :reference, :string
  end
end
