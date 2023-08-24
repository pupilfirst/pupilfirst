class Types::MutationType < Types::BaseObject
  field :update_school_link, mutation: Mutations::UpdateSchoolLink, null: false
  field :move_school_link, mutation: Mutations::MoveSchoolLink, null: false
  field :create_course, mutation: Mutations::CreateCourse, null: false
  field :clone_course, mutation: Mutations::CloneCourse, null: false
  field :update_course, mutation: Mutations::UpdateCourse, null: false
  field :archive_course, mutation: Mutations::ArchiveCourse, null: false
  field :unarchive_course, mutation: Mutations::UnarchiveCourse, null: false
  field :create_school_link, mutation: Mutations::CreateSchoolLink, null: false
  field :destroy_school_link,
        mutation: Mutations::DestroySchoolLink,
        null: false
  field :update_school_string,
        mutation: Mutations::UpdateSchoolString,
        null: false
  field :undo_submission, mutation: Mutations::UndoSubmission, null: false
  field :create_target, mutation: Mutations::CreateTarget, null: false
  field :create_community, mutation: Mutations::CreateCommunity, null: false
  field :update_community, mutation: Mutations::UpdateCommunity, null: false
  field :create_quiz_submission,
        mutation: Mutations::CreateQuizSubmission,
        null: false
  field :auto_verify_submission,
        mutation: Mutations::AutoVerifySubmission,
        null: false
  field :create_submission, mutation: Mutations::CreateSubmission, null: false
  field :delete_content_block,
        mutation: Mutations::DeleteContentBlock,
        null: false
  field :move_content_block, mutation: Mutations::MoveContentBlock, null: false
  field :create_school_admin,
        mutation: Mutations::CreateSchoolAdmin,
        null: false
  field :update_school_admin,
        mutation: Mutations::UpdateSchoolAdmin,
        null: false
  field :create_course_export,
        mutation: Mutations::CreateCourseExport,
        null: false
  field :sort_curriculum_resources,
        mutation: Mutations::SortCurriculumResources,
        null: false
  field :create_grading, mutation: Mutations::CreateGrading, null: false
  field :undo_grading, mutation: Mutations::UndoGrading, null: false
  field :create_feedback, mutation: Mutations::CreateFeedback, null: false
  field :update_review_checklist,
        mutation: Mutations::UpdateReviewChecklist,
        null: false
  field :delete_school_admin,
        mutation: Mutations::DeleteSchoolAdmin,
        null: false
  field :create_coach_note, mutation: Mutations::CreateCoachNote, null: false
  field :create_students, mutation: Mutations::CreateStudents, null: false
  field :update_student_details,
        mutation: Mutations::UpdateStudentDetails,
        null: false
  field :dropout_student, mutation: Mutations::DropoutStudent, null: false
  field :re_activate_student,
        mutation: Mutations::ReActivateStudent,
        null: false
  field :create_evaluation_criterion,
        mutation: Mutations::CreateEvaluationCriterion,
        null: false
  field :update_evaluation_criterion,
        mutation: Mutations::UpdateEvaluationCriterion,
        null: false
  field :update_school, mutation: Mutations::UpdateSchool, null: false
  field :archive_coach_note, mutation: Mutations::ArchiveCoachNote, null: false
  field :create_markdown_content_block,
        mutation: Mutations::CreateMarkdownContentBlock,
        null: false
  field :create_embed_content_block,
        mutation: Mutations::CreateEmbedContentBlock,
        null: false
  field :update_file_block,
        mutation: Mutations::UpdateFileContentBlock,
        null: false
  field :update_markdown_block,
        mutation: Mutations::UpdateMarkdownContentBlock,
        null: false
  field :update_image_block,
        mutation: Mutations::UpdateImageContentBlock,
        null: false
  field :update_target, mutation: Mutations::UpdateTarget, null: false
  field :create_target_version,
        mutation: Mutations::CreateTargetVersion,
        null: false
  field :delete_course_author,
        mutation: Mutations::DeleteCourseAuthor,
        null: false
  field :create_course_author,
        mutation: Mutations::CreateCourseAuthor,
        null: false
  field :update_course_author,
        mutation: Mutations::UpdateCourseAuthor,
        null: false
  field :delete_coach_student_enrollment,
        mutation: Mutations::DeleteCoachStudentEnrollment,
        null: false
  field :create_topic, mutation: Mutations::CreateTopic, null: false
  field :update_topic, mutation: Mutations::UpdateTopic, null: false
  field :create_post, mutation: Mutations::CreatePost, null: false
  field :update_post, mutation: Mutations::UpdatePost, null: false
  field :create_post_like, mutation: Mutations::CreatePostLike, null: false
  field :delete_post_like, mutation: Mutations::DeletePostLike, null: false
  field :mark_post_as_solution,
        mutation: Mutations::MarkPostAsSolution,
        null: false
  field :unmark_post_as_solution,
        mutation: Mutations::UnmarkPostAsSolution,
        null: false
  field :archive_post, mutation: Mutations::ArchivePost, null: false
  field :merge_levels, mutation: Mutations::MergeLevels, null: false
  field :create_vimeo_video, mutation: Mutations::CreateVimeoVideo, null: false
  field :initiate_account_deletion,
        mutation: Mutations::InitiateAccountDeletion,
        null: false
  field :delete_account, mutation: Mutations::DeleteAccount, null: false
  field :update_user, mutation: Mutations::UpdateUser, null: false
  field :send_update_email_token,
        mutation: Mutations::SendUpdateEmailToken,
        null: false
  field :update_certificate, mutation: Mutations::UpdateCertificate, null: false
  field :delete_certificate, mutation: Mutations::DeleteCertificate, null: false
  field :resolve_embed_code, mutation: Mutations::ResolveEmbedCode, null: false
  field :create_topic_category,
        mutation: Mutations::CreateTopicCategory,
        null: false
  field :delete_topic_category,
        mutation: Mutations::DeleteTopicCategory,
        null: false
  field :update_topic_category,
        mutation: Mutations::UpdateTopicCategory,
        null: false
  field :mark_notification, mutation: Mutations::MarkNotification, null: false
  field :mark_all_notifications,
        mutation: Mutations::MarkAllNotifications,
        null: false
  field :create_topic_subscription,
        mutation: Mutations::CreateTopicSubscription,
        null: false
  field :delete_topic_subscription,
        mutation: Mutations::DeleteTopicSubscription,
        null: false
  field :create_web_push_subscription,
        mutation: Mutations::CreateWebPushSubscription,
        null: false
  field :delete_web_push_subscription,
        mutation: Mutations::DeleteWebPushSubscription,
        null: false
  field :issue_certificate, mutation: Mutations::IssueCertificate, null: false
  field :revoke_issued_certificate,
        mutation: Mutations::RevokeIssuedCertificate,
        null: false
  field :lock_topic, mutation: Mutations::LockTopic, null: false
  field :unlock_topic, mutation: Mutations::UnlockTopic, null: false
  field :create_student_from_applicant,
        mutation: Mutations::CreateStudentFromApplicant,
        null: false
  field :clone_level, mutation: Mutations::CloneLevel, null: false
  field :assign_reviewer, mutation: Mutations::AssignReviewer, null: false
  field :reassign_reviewer, mutation: Mutations::ReassignReviewer, null: false
  field :unassign_reviewer, mutation: Mutations::UnassignReviewer, null: false
  field :queue_submission_report,
        mutation: Mutations::QueueSubmissionReport,
        null: false
  field :begin_processing_submission_report,
        mutation: Mutations::BeginProcessingSubmissionReport,
        null: false
  field :conclude_submission_report,
        mutation: Mutations::ConcludeSubmissionReport,
        null: false
  field :create_cohort, mutation: Mutations::CreateCohort, null: false
  field :update_cohort, mutation: Mutations::UpdateCohort, null: false
  field :merge_cohort, mutation: Mutations::MergeCohort, null: false
  field :create_team, mutation: Mutations::CreateTeam, null: false
  field :update_team, mutation: Mutations::UpdateTeam, null: false
  field :destroy_team, mutation: Mutations::DestroyTeam, null: false
  field :re_run_github_action,
        mutation: Mutations::ReRunGithubAction,
        null: false
  field :initiate_password_reset,
        mutation: Mutations::InitiatePasswordReset,
        null: false
end
