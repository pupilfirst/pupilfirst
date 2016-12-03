class RemovePhoneVerificationFieldsFromFounder < ActiveRecord::Migration[5.0]
  def change
    remove_column :founders, :phone_verification_code, :string
    remove_column :founders, :unconfirmed_phone, :string
    remove_column :founders, :verification_code_sent_at, :datetime
  end
end
