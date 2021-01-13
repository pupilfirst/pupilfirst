class AddIdentificationProofToFounders < ActiveRecord::Migration[4.2]
  def change
    add_column :founders, :identification_proof, :string
  end
end
