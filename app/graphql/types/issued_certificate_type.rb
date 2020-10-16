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
      object.revoked_by&.name
    end

    def issued_by
      object.issuer&.name || 'Auto-issued'
    end
  end
end
