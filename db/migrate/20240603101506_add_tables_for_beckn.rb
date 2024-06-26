class AddTablesForBeckn < ActiveRecord::Migration[7.0]
  def change
    create_table :course_ratings do |t|
      t.integer :rating, null: false
      t.references :course, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    create_table :course_categories do |t|
      t.string :name, null: false
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end

    create_table :courses_course_categories do |t|
      t.references :course, null: false, foreign_key: true
      t.references :course_category, null: false, foreign_key: true

      t.timestamps
    end
    add_index :course_ratings, %i[user_id course_id], unique: true

    add_column :schools, :beckn_enabled, :boolean, default: false, null: false
    add_column :courses, :beckn_enabled, :boolean, default: false, null: false

    add_column :students, :metadata, :jsonb, default: {}, null: false
  end
end
