module Types
  class CommunityType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false

    # def grades_and_labels
    #   object.grade_labels.map do |grade, label|
    #     { grade: grade.to_i, label: label }
    #   end
    # end
  end
end
