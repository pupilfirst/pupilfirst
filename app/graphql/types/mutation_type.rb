module Types
  class MutationType < Types::BaseObject
    field :create_course, mutation: Mutations::CreateCourse, null: false
    field :update_course, mutation: Mutations::UpdateCourse, null: false
    field :create_school_link, mutation: Mutations::CreateSchoolLink, null: false
    field :destroy_school_link, mutation: Mutations::DestroySchoolLink, null: false
    field :update_school_string, mutation: Mutations::UpdateSchoolString, null: false
    field :undo_submission, mutation: Mutations::UndoSubmission, null: false
    field :complete_target, mutation: Mutations::CompleteTarget, null: false
  end
end
