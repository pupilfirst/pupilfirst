class AddUniqueIndexToQuizTarget < ActiveRecord::Migration[6.1]

  class Quiz < ApplicationRecord; end

  def up
    puts 'Finding duplicate target_id records for Quizzes...'

    duplicates = Quiz.group(
      :target_id
    ).having('COUNT(*) > 1')

    if duplicates.exists?
      puts 'Found duplicates...'
      puts 'Deleting the duplicates...'

      duplicate_records = Quiz.where(
        target_id: duplicates.pluck(:target_id)
      )

      duplicate_records.find_each do |duplicate|
        puts "Deleting duplicate for quiz.id: #{duplicate.id}..."
        # Find and keep one of the duplicates
        keep_one = Quiz.find_by(target_id: duplicate.target_id)

        # Find all duplicates with the same values and delete them
        duplicates_to_delete = Quiz.where(
          target_id: duplicate.target_id
        ).where.not(id: keep_one.id)

        duplicates_to_delete.delete_all
      end
    end

    puts "Successfully resolved records duplicate issue!"

    remove_index :quizzes, name: 'index_quizzes_on_target_id'
    add_index :quizzes, :target_id, unique: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
