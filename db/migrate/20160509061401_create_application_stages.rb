class CreateApplicationStages < ActiveRecord::Migration
  def change
    create_table :application_stages do |t|
      t.string :name
      t.integer :number

      t.timestamps null: false
    end
  end
end
