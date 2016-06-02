class CreateApplicationFounders < ActiveRecord::Migration
  def change
    create_table :application_founders do |t|
      t.references :batch_application, index: true
      t.string :name
      t.string :gender
      t.string :email
      t.string :phone
      t.string :role
      t.boolean :team_lead

      t.timestamps null: false
    end
  end
end
