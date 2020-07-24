class AddNameToCertificate < ActiveRecord::Migration[6.0]
  class Certificate < ApplicationRecord
  end

  def change
    add_column :certificates, :name, :string
    Certificate.update_all name: 'Default'
    change_column_null :certificates, :name, false
  end
end
