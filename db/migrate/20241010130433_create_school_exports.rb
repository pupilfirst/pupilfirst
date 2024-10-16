class CreateSchoolExports < ActiveRecord::Migration[7.1]
  def change
    create_table :school_exports do |t|
      t.references :school, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :completed_at
      t.string :error_messages, array: true, default: []
      t.timestamps
    end
  end
end
