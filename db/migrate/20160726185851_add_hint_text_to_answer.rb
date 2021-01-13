class AddHintTextToAnswer < ActiveRecord::Migration[4.2]
  def change
    add_column :answer_options, :hint_text, :text
  end
end
