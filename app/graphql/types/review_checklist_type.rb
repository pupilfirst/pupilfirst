module Types
  class ReviewChecklistType < Types::BaseObject
    field :title, String, null: false
    field :result, [Types::ReviewChecklistResultType], null: false
  end
end
