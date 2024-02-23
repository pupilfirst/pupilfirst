class AddUniqueIndexReactionModerationReport < ActiveRecord::Migration[7.0]
  def up
    duplicates =
      Reaction
        .select(:user_id, :reactionable_type, :reactionable_id, :reaction_value)
        .group(:user_id, :reactionable_type, :reactionable_id, :reaction_value)
        .having("COUNT(*) > 1")
    duplicates.each do |duplicate|
      Reaction
        .where(
          user_id: duplicate.user_id,
          reactionable_type: duplicate.reactionable_type,
          reactionable_id: duplicate.reactionable_id,
          reaction_value: duplicate.reaction_value
        )
        .order(created_at: :desc)
        .offset(1)
        .destroy_all
    end

    add_index :moderation_reports,
              %i[user_id reportable_type reportable_id],
              unique: true,
              name: "index_moderation_reports_on_user_and_reportable"
    add_index :reactions,
              %i[user_id reactionable_type reactionable_id reaction_value],
              unique: true,
              name: "index_reactions_on_user_and_reactionable"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
