module Types
  class StudentType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :title, String, null: false
    field :avatar_url, String, null: true
  end
end
