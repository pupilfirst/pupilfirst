class RenameFounderFeeToUndiscountedFounderFee < ActiveRecord::Migration[5.1]
  def change
    rename_column :startups, :founder_fee, :undiscounted_founder_fee
  end
end
