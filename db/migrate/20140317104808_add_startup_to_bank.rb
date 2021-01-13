class AddStartupToBank < ActiveRecord::Migration[4.2]
  def change
    add_reference :banks, :startup, index: true
  end
end
