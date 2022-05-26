module Types
  class CoachType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: false

    def user
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch(default_value: []) do |user_ids, loader|
          User.where(id: user_ids).each { |user| loader.call(user.id, user) }
        end
    end
  end
end
