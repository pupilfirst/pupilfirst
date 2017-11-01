class RenameQuizAttemptToMoocQuizAttempt < ActiveRecord::Migration[5.1]
  def change
    rename_table :quiz_attempts, :mooc_quiz_attempts
  end
end
