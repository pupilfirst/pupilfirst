module Types
  class StudentType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :title, String, null: false
    field :avatar_url, String, null: true
    field :last_seen_at, GraphQL::Types::ISO8601DateTime, null: true
    field :user_tags, [String], null: false

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

    def last_seen_at
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch do |user_ids, loader|
          User
            .where(id: user_ids)
            .each { |user| loader.call(user.id, user.last_seen_at || user.current_sign_in_at) }
        end
    end

    def user_tags
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch do |user_ids, loader|
          tags =
            User
              .joins(taggings: :tag)
              .where(id: user_ids)
              .distinct('tags.name')
              .select(:id, 'array_agg(tags.name)')
              .group(:id)
              .reduce({}) do |acc, user|
                acc[user.id] = user.array_agg
                acc
              end
          user_ids.each { |id| loader.call(id, tags.fetch(id, [])) }
        end
    end
  end
end
