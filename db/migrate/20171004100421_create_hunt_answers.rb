class CreateHuntAnswers < ActiveRecord::Migration[5.1]
  def change
    create_table :hunt_answers do |t|
      t.integer :stage
      t.string :answer

      t.timestamps
    end
  end
end
