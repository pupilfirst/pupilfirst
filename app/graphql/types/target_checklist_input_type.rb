module Types
  class TargetChecklistInputType < Types::BaseInputObject
    argument :title, String, required: true
    argument :action, String, required: true
    argument :optional, Boolean, required: true
  end
end
