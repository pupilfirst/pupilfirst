class CreateStartupQuotes < ActiveRecord::Migration[5.1]
  def change
    create_table :startup_quotes do |t|
      t.string :guid
      t.string :link
      t.integer :post_count, default: 0

      t.timestamps
    end

    add_index :startup_quotes, :guid
    add_index :startup_quotes, :post_count
  end
end
