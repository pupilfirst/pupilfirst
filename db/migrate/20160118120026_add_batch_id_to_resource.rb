class AddBatchIdToResource < ActiveRecord::Migration
  def change
    add_reference :resources, :batch, index: true, foreign_key: true
  end
end
