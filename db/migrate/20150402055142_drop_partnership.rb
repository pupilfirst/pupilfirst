class DropPartnership < ActiveRecord::Migration
  def up
    drop_table :partnerships
  end

  def down
    # Backing up the schema.
    create_table 'partnerships', force: :cascade do |t|
      t.integer 'user_id'
      t.integer 'startup_id'
      t.integer 'salary'
      t.integer 'cash_contribution'
      t.boolean 'managing_partner'
      t.boolean 'operate_bank_account'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.decimal  'share_percentage',             precision: 5, scale: 2
      t.datetime 'confirmed_at'
      t.string 'confirmation_token'
      t.integer 'bank_account_operation_limit'
    end

    add_index 'partnerships', ['startup_id'], name: 'index_partnerships_on_startup_id', using: :btree
    add_index 'partnerships', ['user_id'], name: 'index_partnerships_on_user_id', using: :btree
  end
end
