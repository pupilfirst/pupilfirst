class AddValueToAnswerOption < ActiveRecord::Migration[4.2]
  def change
    add_column :answer_options, :value, :string
  end
end
