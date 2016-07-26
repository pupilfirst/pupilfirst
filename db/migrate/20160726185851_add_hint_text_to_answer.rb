class AddHintTextToAnswer < ActiveRecord::Migration
  def change
    add_column :answer_options, :hint_text, :text
  end
end
