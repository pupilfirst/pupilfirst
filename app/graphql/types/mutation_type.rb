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
    field :create_target, mutation: Mutations::CreateTarget, null: false
    field :update_target, mutation: Mutations::UpdateTarget, null: false
    field :create_question, mutation: Mutations::CreateQuestion, null: false
    field :create_community, mutation: Mutations::CreateCommunity, null: false
    field :update_community, mutation: Mutations::UpdateCommunity, null: false
    field :archive_community_resource, mutation: Mutations::ArchiveCommunityResource, null: false
    field :update_question, mutation: Mutations::UpdateQuestion, null: false
    field :update_answer, mutation: Mutations::UpdateAnswer, null: false
    field :create_quiz_submission, mutation: Mutations::CreateQuizSubmission, null: false
    field :auto_verify_submission, mutation: Mutations::AutoVerifySubmission, null: false
    field :create_submission, mutation: Mutations::CreateSubmission, null: false
    field :delete_content_block, mutation: Mutations::DeleteContentBlock, null: false
    field :level_up, mutation: Mutations::LevelUp, null: false
  end
end
