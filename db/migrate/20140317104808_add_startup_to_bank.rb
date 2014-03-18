class AddStartupToBank < ActiveRecord::Migration
  def change
    add_reference :banks, :startup, index: true
  end
end
