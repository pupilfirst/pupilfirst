class AddBatchIdToResource < ActiveRecord::Migration[4.2]
  def change
    add_reference :resources, :batch, index: true, foreign_key: true
  end
end
