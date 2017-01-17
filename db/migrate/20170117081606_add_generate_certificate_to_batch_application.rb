class AddGenerateCertificateToBatchApplication < ActiveRecord::Migration[5.0]
  def change
    add_column :batch_applications, :generate_certificate, :boolean, default: :false
  end
end
