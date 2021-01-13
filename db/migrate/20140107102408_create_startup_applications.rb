class CreateStartupApplications < ActiveRecord::Migration[4.2]
  def change
    create_table :startup_applications do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.text :idea
      t.string :website

      t.timestamps
    end
  end
end
