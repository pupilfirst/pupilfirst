class ChangeNullValueForUserInIssuedCertificates < ActiveRecord::Migration[6.0]
  def change
    change_column_null :issued_certificates, :user_id, true
  end
end
