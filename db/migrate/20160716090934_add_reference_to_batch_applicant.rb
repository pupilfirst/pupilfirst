class AddReferenceToBatchApplicant < ActiveRecord::Migration
  def change
    add_column :batch_applicants, :reference, :string
  end
end
