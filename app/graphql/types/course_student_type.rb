module Types
  class CourseStudentType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false
    field :title, String, null: false
    field :affiliation, String, null: true
    field :avatar_url, String, null: true
    field :excluded_from_leaderboard, Boolean, null: false
    field :tags, [String], null: false
  end
end
