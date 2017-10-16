class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.string :name
      t.string :phone
      t.references :college, foreign_key: true
      t.string :college_text
      t.integer :stage, default: 0
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
