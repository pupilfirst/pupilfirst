module Types
  class UserProxyType < Types::BaseObject
    field :id,
          ID,
          null: false,
          description:
            'The ID returned by the type can represent different user role types'
    field :user_id, ID, null: false
    field :name, String, null: false
    field :full_title, String, null: false
    field :avatar_url, String, null: true
    field :preferred_name, String, null: true

    def avatar_url
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch do |user_ids, loader|
          User
            .includes(avatar_attachment: :blob)
            .where(id: user_ids)
            .each do |user|
              if user.avatar.attached?
                url =
                  Rails.application.routes.url_helpers.rails_public_blob_url(
                    user.avatar_variant(:thumb)
                  )
                loader.call(user.id, url)
              end
            end
        end
    end

    def preferred_name
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch do |user_ids, loader|
          User
            .where(id: user_ids)
            .each { |user| loader.call(user.id, user.preferred_name) }
        end
    end

    def name
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch do |user_ids, loader|
          User
            .where(id: user_ids)
            .each { |user| loader.call(user.id, user.name) }
        end
    end

    def full_title
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch do |user_ids, loader|
          User
            .where(id: user_ids)
            .each { |user| loader.call(user.id, user.full_title) }
        end
    end
  end
end
