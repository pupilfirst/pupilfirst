class AddUniqueIndexToQuizTarget < ActiveRecord::Migration[6.1]

  class Quiz < ApplicationRecord; end

  def up
    puts 'Finding duplicate target_id records for Quizzes...'
    Quiz.select('MAX(created_at) as latest_time, target_id')
        .group(:target_id)
        .having('COUNT(*) > 1')
        .each do |duplicate|
      most_recent_record = Quiz.where(target_id: duplicate.target_id)
                               .order(created_at: :desc)
                               .first
      Quiz.where(target_id: duplicate.target_id)
          .where.not(id: most_recent_record.id)
          .delete_all
    end

    puts "Successfully resolved records duplicate issue!"

    remove_index :quizzes, name: 'index_quizzes_on_target_id'
    add_index :quizzes, :target_id, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
