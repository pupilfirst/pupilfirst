module Types
  class CoachNoteType < Types::BaseObject
    field :id, ID, null: false
    field :author, Types::UserType, null: true
    field :note, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    def author
      BatchLoader::GraphQL.for(object.author_id).batch do |user_ids, loader|
        User.where(id: user_ids).each do |user|
          loader.call(user.id, user)
        end
      end
    end
  end
end
