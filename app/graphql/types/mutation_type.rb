module Types
  class MutationType < Types::BaseObject
    field :create_course, mutation: Mutations::CreateCourse, null: false
    field :update_course, mutation: Mutations::UpdateCourse, null: false
    field :create_school_link, mutation: Mutations::CreateSchoolLink, null: false
    field :destroy_school_link, mutation: Mutations::DestroySchoolLink, null: false
  end
end
