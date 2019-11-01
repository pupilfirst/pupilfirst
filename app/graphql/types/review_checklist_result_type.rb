module Types
  class ReviewChecklistResultType < Types::BaseObject
    field :title, String, null: false
    field :feedback, String, null: true
  end
end
