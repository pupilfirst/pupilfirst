module Types
  class ReviewChecklistType < Types::BaseObject
    field :title, String, null: false
    field :checklist, [Types::ReviewChecklistResultType], null: false
  end
end
