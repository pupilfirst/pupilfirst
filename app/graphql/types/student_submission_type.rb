module Types
  class StudentSubmissionType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :created_at, String, null: false
    field :passed_at, String, null: true
  end
end
