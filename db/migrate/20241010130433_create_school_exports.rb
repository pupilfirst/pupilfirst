class CreateSchoolExports < ActiveRecord::Migration[7.1]
  def change
    create_table :school_exports do |t|
      t.references :school, null: false, foreign_key: true
      t.bigint :created_by_id, index: true
      t.string :tables, null: false, array: true, default: []

      t.timestamps
    end

    add_foreign_key :school_exports, :users, column: :created_by_id
  end
end
