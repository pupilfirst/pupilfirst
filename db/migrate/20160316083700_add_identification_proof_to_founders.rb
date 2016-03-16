class AddIdentificationProofToFounders < ActiveRecord::Migration
  def change
    add_column :founders, :identification_proof, :string
  end
end
