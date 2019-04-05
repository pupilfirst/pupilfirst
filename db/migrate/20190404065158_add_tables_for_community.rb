class AddTablesForCommunity < ActiveRecord::Migration[5.2]
  def up
    create_table :community do |t|
      t.string :name
      t.string :slug
      t.references :school
      t.index :slug, unique: true
      t.timestamps
    end

    create_table :questions do |t|
      t.string :title
      t.text :description
      t.references :community_dashboard
      t.references :user
      t.references :targets

      t.timestamps
    end

    create_table :answers do |t|
      t.text :description
      t.references :question
      t.references :user

      t.timestamps
    end

    create_table :answer_claps do |t|
      t.integer :count
      t.references :answer
      t.references :user

      t.timestamps
    end

    add_reference :courses, :community
  end

  def down
    remove_reference :courses, :community
    drop_table :community
    drop_table :questions
    drop_table :answers
    drop_table :answer_claps
  end
end
