class CreateAnswerOptions < ActiveRecord::Migration
  def change
    create_table :answer_options do |t|

      t.timestamps null: false
    end
  end
end
