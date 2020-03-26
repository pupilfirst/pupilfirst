module Types
  class CoachStatsType < Types::BaseObject
    field :reviewed_submissions, Integer, null: false
    field :pending_submissions, Integer, null: false
  end
end
