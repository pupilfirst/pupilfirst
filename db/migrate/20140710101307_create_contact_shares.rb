class CreateContactShares < ActiveRecord::Migration
  def change
    create_table :contact_shares do |t|
      t.integer :contact_id
      t.integer :user_id
      t.string :share_direction

      t.timestamps
    end

    add_index :contact_shares, :contact_id
    add_index :contact_shares, :user_id
  end
end
