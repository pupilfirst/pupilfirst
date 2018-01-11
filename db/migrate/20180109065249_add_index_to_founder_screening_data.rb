class AddIndexToFounderScreeningData < ActiveRecord::Migration[5.1]
  def change
    add_index :founders, "(screening_data->'score')", using: :gin, name: 'index_founders_on_screening_data_score'
  end
end
