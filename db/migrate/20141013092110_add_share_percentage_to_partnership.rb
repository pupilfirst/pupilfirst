class AddSharePercentageToPartnership < ActiveRecord::Migration[4.2]
  def change
    add_column :partnerships, :share_percentage, :decimal, precision: 5, scale: 2
  end
end
