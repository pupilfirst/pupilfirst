class AddCorrectAnswerToAnswerOption < ActiveRecord::Migration[4.2]
  def change
    add_column :answer_options, :correct_answer, :boolean, default: false
  end
end
