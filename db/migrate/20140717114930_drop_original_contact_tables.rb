class DropOriginalContactTables < ActiveRecord::Migration
  def up
    drop_table :contacts
    drop_table :contact_shares
    drop_table :categories_contacts
  end

  def down
    # Table contacts
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

    # Table contact_shares
    create_table :contact_shares do |t|
      t.integer :contact_id
      t.integer :user_id
      t.string :share_direction

      t.timestamps
    end

    add_index :contact_shares, :contact_id
    add_index :contact_shares, :user_id

    # Table categories_contacts
    create_table :categories_contacts, id: false do |t|
      t.belongs_to :category
      t.belongs_to :contact
    end
  end
end
