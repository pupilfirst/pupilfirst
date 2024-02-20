module Types
  class ReactionType < Types::BaseObject
    field :id, ID, null: false
    field :user_id, ID, null: false
    field :reactionable_id, ID, null: true
    field :reaction_value, String, null: false
    field :reactionable_type, String, null: false
    field :user_name, String, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    def user_name
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |reaction_ids, loader|
          Reaction
            .includes(:user)
            .where(id: reaction_ids)
            .each { |reaction| loader.call(reaction.id, reaction.user.name) }
        end
    end
  end
end
