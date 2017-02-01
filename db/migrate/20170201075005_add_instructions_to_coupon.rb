class AddInstructionsToCoupon < ActiveRecord::Migration[5.0]
  def change
    add_column :coupons, :instructions, :text
  end
end
