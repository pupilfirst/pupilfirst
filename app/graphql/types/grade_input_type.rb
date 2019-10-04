module Types
  class GradeInputType < Types::BaseInputObject
    argument :evaluation_criterion_id, ID, required: true
    argument :grade, Int, required: true
  end
end
