class UpdateEmptyLastActivityInTopics < ActiveRecord::Migration[6.1]
  def up
    Topic
      .where(last_activity_at: nil)
      .each do |topic|
        last_activity_at =
          if topic.replies.exists?
            topic.replies.last.updated_at
          else
            topic.updated_at
          end

        topic.update!(last_activity_at: last_activity_at)
      end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
