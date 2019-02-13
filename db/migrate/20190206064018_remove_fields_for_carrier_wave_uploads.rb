class RemoveFieldsForCarrierWaveUploads < ActiveRecord::Migration[5.2]
  def change
    remove_column :founders, :college_identification, :string
    remove_column :founders, :identification_proof, :string
    remove_column :founders, :address_proof, :string
    remove_column :founders, :income_proof, :string
    remove_column :founders, :letter_from_parent, :string
    remove_column :startups, :partnership_deed, :string
    remove_column :targets, :rubric, :string
    remove_column :admin_users, :avatar, :string
    remove_column :platform_feedback, :attachment, :string
    remove_column :startups, :logo, :string
    remove_column :resources, :thumbnail, :string
  end
end
