class CreateApplicationRounds < ActiveRecord::Migration[5.0]
  def change
    create_table :application_rounds do |t|
      t.references :batch, foreign_key: true
      t.integer :number
      t.datetime :starts_at
      t.datetime :ends_at
      t.datetime :campaign_start_at
      t.integer :target_application_count

      t.timestamps
    end
  end
end
