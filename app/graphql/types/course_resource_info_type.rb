module Types
  class CourseResourceInfoType < Types::BaseObject
    field :resource, Types::CourseResourceType, null: false
    field :values, [String], null: false
  end
end
