class AddCoderToFounder < ActiveRecord::Migration[5.1]
  def change
    add_column :founders, :coder, :boolean
  end
end
