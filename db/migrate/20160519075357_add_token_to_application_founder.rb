class AddTokenToApplicationFounder < ActiveRecord::Migration
  def change
    add_column :application_founders, :token, :string
    add_index :application_founders, :token
  end
end
