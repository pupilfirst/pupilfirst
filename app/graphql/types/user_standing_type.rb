module Types
  class UserStandingType < BaseObject
    field :id, ID, null: false
    field :standing_name, String, null: false
    field :standing_color, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :creator_name, String, null: false
    field :reason, String, null: false

    def creator_name
      BatchLoader::GraphQL
        .for(object.creator_id)
        .batch do |creator_ids, loader|
          User
            .where(id: creator_ids)
            .each { |user| loader.call(user.id, user.name) }
        end
      # object.creator.name
    end

    def standing_name
      BatchLoader::GraphQL
        .for(object.standing_id)
        .batch do |standing_ids, loader|
          Standing
            .where(id: standing_ids)
            .each { |standing| loader.call(standing.id, standing.name) }
        end
      # object.standing.name
    end

    def standing_color
      BatchLoader::GraphQL
        .for(object.standing_id)
        .batch do |standing_ids, loader|
          Standing
            .where(id: standing_ids)
            .each { |standing| loader.call(standing.id, standing.color) }
        end
      # object.standing.color
    end
  end
end
