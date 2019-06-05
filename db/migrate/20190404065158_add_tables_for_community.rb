class AddTablesForCommunity < ActiveRecord::Migration[5.2]
  def up
    create_table :communities do |t|
      t.string :name
      t.boolean :target_linkable, default: false
      t.references :school, foreign_key: true

      t.timestamps
    end

    create_table :questions do |t|
      t.string :title
      t.text :description
      t.references :community
      t.references :creator
      t.references :editor
      t.references :archiver
      t.boolean :archived, default: false
      t.datetime :last_activity_at

      t.timestamps
    end

    create_table :answers do |t|
      t.text :description
      t.references :question
      t.references :creator
      t.references :editor
      t.references :archiver
      t.boolean :archived, default: false

      t.timestamps
    end

    create_table :answer_likes do |t|
      t.references :answer, index: false
      t.references :user

      t.timestamps
    end

    create_table :comments do |t|
      t.text :value
      t.references :commentable, polymorphic: true, index: true
      t.datetime :archived_at
      t.references :creator
      t.references :editor
      t.references :archiver
      t.boolean :archived, default: false

      t.timestamps
    end

    create_table :text_versions do |t|
      t.text :value
      t.references :versionable, polymorphic: true, index: true
      t.references :user
      t.datetime :edited_at

      t.timestamps
    end

    create_table :target_questions do |t|
      t.references :question, foreign_key: true
      t.references :target, foreign_key: true, index: false
    end

    create_table :community_course_connections do |t|
      t.references :community, foreign_key: true
      t.references :course, foreign_key: true, index: false
    end

    add_index :answer_likes, %i[answer_id user_id], unique: true
    add_index :community_course_connections, %i[course_id community_id], unique: true, name: 'index_community_course_connection_on_course_id_and_community_id'
    add_index :target_questions, %i[target_id question_id], unique: true

    add_column :courses, :description, :string
  end

  def down
    drop_table :community_course_connections
    drop_table :target_questions
    drop_table :communities
    drop_table :questions
    drop_table :answers
    drop_table :answer_likes
    drop_table :comments
    drop_table :text_versions
    remove_column :courses, :description, :string
  end
end
