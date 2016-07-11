class AddValueToAnswerOption < ActiveRecord::Migration
  def change
    add_column :answer_options, :value, :string
  end
end
