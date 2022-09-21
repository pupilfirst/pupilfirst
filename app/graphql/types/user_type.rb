module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :title, String, null: false
    field :affiliation, String, null: true
    field :full_title, String, null: false
    field :avatar_url, String, null: true
    field :taggings, [String], null: false
    field :last_seen_at, GraphQL::Types::ISO8601DateTime, null: true
    field :preferred_name, String, null: true
    field :email, String, null: false do
      def authorized?(_object, _args, context)
        context[:current_school_admin].present?
      end
    end

    def avatar_url
      BatchLoader::GraphQL
        .for(object.id)
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

    delegate :last_seen_at, to: :object

    def taggings
      BatchLoader::GraphQL
        .for(object.id)
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
