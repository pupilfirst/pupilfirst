module Types
  class Submission < Types::BaseObject
    field :id, ID, null: false
    field :description, String, null: false
    field :created_at, String, null: false
  end
end
