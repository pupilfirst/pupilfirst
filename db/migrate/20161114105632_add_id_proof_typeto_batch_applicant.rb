class AddIdProofTypetoBatchApplicant < ActiveRecord::Migration[5.0]
  def change
    add_column :batch_applicants, :id_proof_type, :string
  end
end
