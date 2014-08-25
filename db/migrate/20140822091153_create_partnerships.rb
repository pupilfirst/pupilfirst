class CreatePartnerships < ActiveRecord::Migration
  def change
    create_table :partnerships do |t|
      t.references :user, index: true
      t.references :startup, index: true
      t.integer :shares
      t.integer :salary
      t.integer :cash_contribution
      t.boolean :managing_director
      t.boolean :operate_bank_account

      t.timestamps
    end
  end
end
