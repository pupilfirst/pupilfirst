module Types
  class MutationType < Types::BaseObject
    field :create_course, mutation: Mutations::CreateCourse, null: false
    field :update_course, mutation: Mutations::UpdateCourse, null: false
    field :create_school_link, mutation: Mutations::CreateSchoolLink, null: false
    field :destroy_school_link, mutation: Mutations::DestroySchoolLink, null: false
    field :update_school_string, mutation: Mutations::UpdateSchoolString, null: false
    field :create_comment, mutation: Mutations::CreateComment, null: false
    field :create_answer, mutation: Mutations::CreateAnswer, null: false
    field :create_answer_like, mutation: Mutations::CreateAnswerLike, null: false
    field :destroy_answer_like, mutation: Mutations::DestroyAnswerLike, null: false
    field :undo_submission, mutation: Mutations::UndoSubmission, null: false
    field :create_question, mutation: Mutations::CreateQuestion, null: false
    field :create_community, mutation: Mutations::CreateCommunity, null: false
    field :update_community, mutation: Mutations::UpdateCommunity, null: false
    field :archive_community_resource, mutation: Mutations::ArchiveCommunityResource, null: false
  end
end
