class AddAgreementsVerifiedToBatchApplication < ActiveRecord::Migration[5.0]
  def change
    add_column :batch_applications, :agreements_verified, :boolean, default: false
  end
end
