class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.string :mode_of_operation
      t.references :directors, index: true

      t.timestamps
    end
  end
end
