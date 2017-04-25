class AddBatchApplicantFieldsToFounder < ActiveRecord::Migration[5.0]
  def change
    add_column :founders, :fee_payment_method, :string
    add_column :founders, :parent_name, :string
    add_column :founders, :id_proof_type, :string
    add_column :founders, :id_proof_number, :string
    add_column :founders, :income_proof, :string
    add_column :founders, :letter_from_parent, :string
    add_column :founders, :college_contact, :string
    add_column :founders, :permanent_address, :string
    add_column :founders, :address_proof, :string
  end
end
