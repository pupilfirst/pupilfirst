class CreateCommunityV2Tables < ActiveRecord::Migration[6.0]
  class Topic < ApplicationRecord
    has_many :posts
  end

  class Post < ApplicationRecord
    has_many :post_likes
    belongs_to :reply_to_post, class_name: 'Post', optional: true
  end

  class PostLike < ApplicationRecord
  end

  class Comment < ApplicationRecord
    belongs_to :commentable, polymorphic: true
  end

  class AnswerLikes < ApplicationRecord
  end

  class TextVersions < ApplicationRecord
  end

  class Target < ApplicationRecord
  end

  class TargetQuestions < ApplicationRecord
    belongs_to :target
  end

  class Answer < ApplicationRecord
    has_many :answer_likes
    has_many :comments, as: :commentable
    has_many :text_versions, as: :versionable

    def self.name
      'Answer'
    end
  end

  class Question < ApplicationRecord
    has_many :answers
    has_many :comments, as: :commentable
    has_many :target_questions
    has_many :targets, through: :target_questions
    has_many :text_versions, as: :versionable

    def self.name
      'Question'
    end
  end

  def up
    create_table :topics do |t|
      t.references :community, foreign_key: true
      t.references :target
      t.datetime :last_activity_at
      t.boolean :archived, null: false, default: false # Denormalized version of first_post.archived_at.
      t.string :title

      t.timestamps
    end

    create_table :posts do |t|
      t.references :topic, foreign_key: true
      t.references :creator
      t.references :editor
      t.references :archiver
      t.datetime :archived_at
      t.references :reply_to_post, foreign_key: { to_table: :posts }
      t.integer :post_number
      t.text :body
      t.boolean :solution, default: false

      t.timestamps
    end

    create_table :post_likes do |t|
      t.references :post, index: false
      t.references :user

      t.timestamps
    end

    add_index :post_likes, %i[post_id user_id], unique: true

    Topic.reset_column_information
    Post.reset_column_information
    PostLike.reset_column_information

    Question.all.includes(:targets, :text_versions, :comments, answers: %i[text_versions comments]).find_each do |question|
      # Let's use a hash to store likes count. We'll use this at the end to mark a post as a 'solution'.
      likes = {}

      target = question.targets.first

      # Create a thread for each question.
      topic = Topic.create!(
        question.attributes.slice('community_id', 'last_activity_at', 'title', 'created_at', 'updated_at', 'archived').merge(
          target_id: target&.id
        )
      )

      # Create the first post in the topic.
      first_post = topic.posts.create!(post_attributes(question))

      # Assigns versions for question to the new post.
      question.text_versions.update_all(versionable_type: 'Post', versionable_id: first_post.id)

      # Create posts for comments on the question.
      question.comments.each do |comment|
        topic.posts.create!(post_attributes(comment, reply_to: first_post))
      end

      question.answers.each do |answer|
        # Create posts for each answer.
        answer_post = topic.posts.create!(post_attributes(answer))

        # Create posts from comments on answer.
        answer.comments.each do |comment|
          topic.posts.create!(post_attributes(comment, reply_to: answer_post))
        end

        # Assigns versions for answer to the answer's post.
        answer.text_versions.update_all(versionable_type: 'Post', versionable_id: answer_post.id)

        # Assign answer likes to post.
        answer.answer_likes.each do |answer_like|
          answer_post.post_likes.create!(answer_like.attributes.slice('user_id', 'created_at', 'updated_at'))
        end

        likes[answer_post] = answer_post.post_likes.count
      end

      # Mark the answer with the highest likes (non-zero) as the solution.
      most_liked = likes.sort_by { |_k, v| v }.last

      if most_liked.present? && most_liked[1] > 0
        most_liked[0].update!(solution: true)
      end

      # Re-number posts in this question.
      topic.posts.order(created_at: :ASC).each_with_index do |post, i|
        post.update!(post_number: i + 1)
      end
    end

    # Add unique index to posts table now that they've all been numbered.
    add_index :posts, %i[post_number topic_id], unique: true

    # Ensure posts#post_number is not null
    change_column_null :posts, :post_number, false

    # Clean up old tables.
    drop_table :comments
    drop_table :answer_likes
    drop_table :answers
    drop_table :target_questions
    drop_table :questions
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def post_attributes(record, reply_to: nil)
    body = record.class.name.in?(%w[Question Answer]) ? record.description : record.value

    record.attributes.slice('creator_id', 'editor_id', 'archiver_id', 'created_at', 'updated_at').merge(
      archived_at: record.archived ? migration_time : nil,
      reply_to_post: reply_to,
      body: body
    )
  end

  def migration_time
    @migration_time ||= Time.zone.now
  end
end
