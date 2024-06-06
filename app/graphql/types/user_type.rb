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
    field :current_standing_name, String, null: true

    def current_standing_name
      return unless Schools::Configuration.new(object.school).standing_enabled?

      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: default_standing_for_school) do |user_ids, loader|
          UserStanding
            .where(user_id: user_ids, archived_at: nil)
            .order(:user_id, created_at: :desc)
            .each_with_object({}) do |user_standing, current_standings|
              # Ensure we only keep the most recent standing per user
              current_standings[
                user_standing.user_id
              ] ||= user_standing.standing.name
            end
            .each { |user_id, name| loader.call(user_id, name) }
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
              .distinct("tags.name")
              .select(:id, "array_agg(tags.name)")
              .group(:id)
              .reduce({}) do |acc, user|
                acc[user.id] = user.array_agg
                acc
              end
          user_ids.each { |id| loader.call(id, tags.fetch(id, [])) }
        end
    end

    private

    def default_standing_for_school
      @default_standing_for_school ||= object.school.default_standing.name
    end
  end
end
