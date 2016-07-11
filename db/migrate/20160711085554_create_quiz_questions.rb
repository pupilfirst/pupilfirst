class CreateQuizQuestions < ActiveRecord::Migration
  def change
    create_table :quiz_questions do |t|

      t.timestamps null: false
    end
  end
end
