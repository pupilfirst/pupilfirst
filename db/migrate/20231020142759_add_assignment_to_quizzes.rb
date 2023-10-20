class AddAssignmentToQuizzes < ActiveRecord::Migration[6.1]
  def change
    add_reference :quizzes, :assignment, null: true, foreign_key: true
  end
end
