class DropStartupQuotes < ActiveRecord::Migration[5.2]
  def change
    drop_table :startup_quotes
  end
end
