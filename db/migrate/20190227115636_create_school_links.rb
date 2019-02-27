class CreateSchoolLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :school_links do |t|
      t.references :school, foreign_key: true, index: false
      t.string :title
      t.string :url
      t.string :kind

      t.timestamps
    end

    add_index :school_links, %i[school_id kind]
  end
end
