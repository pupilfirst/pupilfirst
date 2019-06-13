module Types
  class Submission < Types::BaseObject
    field :id, ID, null: false
    field :description, String, null: false
    field :createdAt, String, null: false
  end
end
