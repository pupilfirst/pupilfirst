class CreateQuizQuestions < ActiveRecord::Migration[4.2]
  def change
    create_table :quiz_questions do |t|

      t.timestamps null: false
    end
  end
end
