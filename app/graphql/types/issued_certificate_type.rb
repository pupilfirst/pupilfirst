module Types
  class IssuedCertificateType < Types::BaseObject
    field :id, ID, null: false
    field :certificate, Types::CertificateType, null: false
    field :user, UserType, null: false
    field :name, String, null: false
    field :serial_number, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :issued_by, String, null: false
    field :revoked_by, String, null: true
    field :revoked_at, GraphQL::Types::ISO8601DateTime, null: true

    def user
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch do |user_ids, loader|
          User
            .where(id: user_ids)
            .each { |user| loader.call(user.id, user.name) }
        end
    end

    def certificate
      BatchLoader::GraphQL
        .for(object.certificate_id)
        .batch do |certificate_ids, loader|
          Certificate
            .where(id: certificate_ids)
            .each { |certificate| loader.call(certificate.id, certificate) }
        end
    end

    def revoked_by
      BatchLoader::GraphQL
        .for(object.revoker_id)
        .batch do |user_ids, loader|
          User
            .where(id: user_ids)
            .each { |user| loader.call(user.id, user.name) }
        end
    end

    def issued_by
      BatchLoader::GraphQL
        .for(object.issuer_id)
        .batch(default_value: 'Auto-issued') do |user_ids, loader|
          User
            .where(id: user_ids)
            .each { |user| loader.call(user.id, user.name) }
        end
    end
  end
end
