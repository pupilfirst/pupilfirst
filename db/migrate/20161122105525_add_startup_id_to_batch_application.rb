class AddStartupIdToBatchApplication < ActiveRecord::Migration[5.0]
  def change
    add_reference :batch_applications, :startup, foreign_key: true
  end
end
