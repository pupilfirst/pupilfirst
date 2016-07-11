class AddCorrectAnswerToAnswerOption < ActiveRecord::Migration
  def change
    add_column :answer_options, :correct_answer, :boolean, default: false
  end
end
