class AddTablesForCommunity < ActiveRecord::Migration[5.2]
  def up
    create_table :communities do |t|
      t.string :name
      t.string :slug
      t.references :school
      t.index :slug, unique: true
      t.timestamps
    end

    create_table :questions do |t|
      t.string :title
      t.text :description
      t.references :community
      t.references :user

      t.datetime :last_activity_at

      t.timestamps
    end

    create_table :answers do |t|
      t.text :description
      t.references :question
      t.references :user

      t.timestamps
    end

    create_table :answer_likes do |t|
      t.references :answer
      t.references :user

      t.timestamps
    end

    create_table :target_questions do |t|
      t.references :question
      t.references :target
    end

    create_table :comments do |t|
      t.text :value
      t.references :commentable, polymorphic: true, index: true
      t.references :user

      t.timestamps
    end

    add_reference :courses, :community
  end

  def down
    remove_reference :courses, :community
    drop_table :communities
    drop_table :questions
    drop_table :answers
    drop_table :answer_likes
    drop_table :comments
    drop_table :target_question
  end
end
