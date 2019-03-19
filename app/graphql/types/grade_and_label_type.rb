module Types
  class GradeAndLabelType < Types::BaseObject
    field :grade, Integer, null: false
    field :label, String, null: false
  end
end
