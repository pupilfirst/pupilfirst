class AddPostedOnToEnglishQuizQuestion < ActiveRecord::Migration[5.1]
  def change
    add_column :english_quiz_questions, :posted_on, :date
  end
end
