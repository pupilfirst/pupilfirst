class CreateSchoolsAgain < ActiveRecord::Migration[5.2]
  def change
    create_table :schools do |t|
      t.string :name

      t.timestamps
    end

    add_reference :courses, :school, foreign_key: true
    add_reference :faculty, :school, foreign_key: true
  end
end
