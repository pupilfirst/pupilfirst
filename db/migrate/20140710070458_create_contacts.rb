class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :mobile
      t.string :email
      t.string :designation
      t.string :company

      t.timestamps
    end

    add_index :contacts, :mobile
    add_index :contacts, :email
  end
end
