class CreatePageReads < ActiveRecord::Migration[6.1]
  def change
    create_table :page_reads do |t|
      t.references :target, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: true
      t.datetime :created_at
    end
  end
end
