class AddUniqueIndexReactionModerationReport < ActiveRecord::Migration[7.0]
  def change
    add_index :moderation_reports,
              %i[user_id reportable_type reportable_id],
              unique: true,
              name: "index_moderation_reports_on_user_and_reportable"
    add_index :reactions,
              %i[user_id reactionable_type reactionable_id reaction_value],
              unique: true,
              name: "index_reactions_on_user_and_reactionable"
  end
end
