class AddNameToSkills < ActiveRecord::Migration[5.1]
  change_table :skills do |t|
    t.string :name
  end
end
