module Types
  class GradeAndLabelInputType < Types::BaseInputObject
    argument :grade, Integer, required: true
    argument :label, String, required: true
  end
end
