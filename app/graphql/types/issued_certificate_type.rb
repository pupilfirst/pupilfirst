module Types
  class IssuedCertificateType < Types::BaseObject
    field :id, ID, null: false
    field :certificate_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :issued_by, String, null: false
    field :revoked_by, String, null: true
    field :revoked_at, GraphQL::Types::ISO8601DateTime, null: true
    field :serial_number, String, null: false

    def revoked_by
      BatchLoader::GraphQL.for(object.revoker_id).batch do |user_ids, loader|
        User.where(id: user_ids).each do |user|
          loader.call(user.id, user.name)
        end
      end
    end

    def issued_by
      BatchLoader::GraphQL.for(object.issuer_id).batch(default_value: 'Auto-issued') do |user_ids, loader|
        User.where(id: user_ids).each do |user|
          loader.call(user.id, user.name)
        end
      end
    end
  end
end
