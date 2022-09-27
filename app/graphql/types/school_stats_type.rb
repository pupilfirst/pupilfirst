module Types
  class SchoolStatsType < Types::BaseObject
    field :students_count, Integer, null: false
    field :coaches_count, Integer, null: false
  end
end
