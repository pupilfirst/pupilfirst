module Courses
  # Permanently deletes all data related to a course
  class DeleteService
    def initialize(course)
      @course = course
    end

    def execute
      Course.transaction do
        delete_applicants
        delete_certificates
        delete_community_course_connections
        delete_course_authors
        delete_course_exports
        delete_evaluation_criteria
        delete_cohorts
        delete_levels

        @course.reload.destroy!
      end
    end

    private

    def delete_applicants
      Applicant.where(course_id: @course.id).delete_all
    end

    def delete_certificates
      IssuedCertificate.where(
        certificate_id: @course.certificates.select(:id)
      ).delete_all
      @course.certificates.find_each(&:destroy!)
    end

    def delete_community_course_connections
      CommunityCourseConnection.where(course_id: @course.id).delete_all
    end

    def delete_course_authors
      CourseAuthor.joins(:course).where(courses: { id: @course.id }).delete_all
    end

    def delete_course_exports
      ActsAsTaggableOn::Tagging.where(
        taggable_type: "CourseExport",
        taggable_id: @course.course_exports.select(:id)
      ).delete_all
      @course.course_exports.find_each(&:destroy!)
    end

    def delete_evaluation_criteria
      evaluation_criteria = EvaluationCriterion.where(course_id: @course.id)

      AssignmentsEvaluationCriterion.where(
        evaluation_criterion_id: evaluation_criteria
      ).delete_all
      TimelineEventGrade.where(
        evaluation_criterion_id: evaluation_criteria
      ).delete_all
      evaluation_criteria.delete_all
    end

    def delete_levels
      delete_content

      Level.where(course_id: @course.id).delete_all
    end

    def delete_page_reads
      PageRead
        .joins(student: :course)
        .where(courses: { id: @course.id })
        .delete_all
    end

    def delete_submissions
      timeline_event_owners =
        TimelineEventOwner.joins(student: :course).where(
          courses: {
            id: @course.id
          }
        )
      submission_ids =
        timeline_event_owners.distinct(:timeline_event_id).pluck(
          :timeline_event_id
        )

      TimelineEventFile
        .joins(timeline_event: { students: :course })
        .where(courses: { id: @course.id })
        .destroy_all
      timeline_event_owners.delete_all
      StartupFeedback.where(timeline_event_id: submission_ids).delete_all
      TimelineEvent.where(id: submission_ids).destroy_all
    end

    def delete_content
      quiz_questions =
        QuizQuestion.joins(quiz: { assignment: :course }).where(
          courses: {
            id: @course.id
          }
        )
      target_ids =
        Target.joins(:course).where(courses: { id: @course.id }).select(:id)

      quiz_questions.update_all(correct_answer_id: nil) # rubocop:disable Rails/SkipsModelValidations
      AnswerOption
        .joins(quiz_question: { quiz: { assignment: :course } })
        .where(courses: { id: @course.id })
        .delete_all
      quiz_questions.delete_all
      Quiz
        .joins(assignment: :course)
        .where(courses: { id: @course.id })
        .delete_all
      ContentBlock
        .joins(target_version: { target: :course })
        .where(courses: { id: @course.id })
        .delete_all
      TargetVersion
        .joins(target: :course)
        .where(courses: { id: @course.id })
        .delete_all
      assignments =
        Assignment.joins(target: :course).where(courses: { id: @course.id })
      AssignmentsPrerequisiteAssignment.where(
        assignment: assignments
      ).delete_all
      assignments.delete_all
      ResourceVersion.where(
        versionable_type: "Target",
        versionable_id: @course.targets.select(:id)
      ).delete_all
      Topic.where(target_id: target_ids).update_all(target_id: nil) # rubocop:disable Rails/SkipsModelValidations
      Target.joins(:course).where(courses: { id: @course.id }).delete_all
      TargetGroup.joins(:course).where(courses: { id: @course.id }).delete_all
    end

    def delete_cohorts
      cohort_ids = @course.cohorts.select(:id)
      student_ids = Student.where(cohort_id: cohort_ids).select(:id)

      # clean up submissions and page reads
      delete_submissions
      delete_page_reads

      # clean up enrollments and coach notes
      FacultyCohortEnrollment.where(cohort_id: cohort_ids).delete_all
      FacultyStudentEnrollment.where(student_id: student_ids).delete_all
      CoachNote.joins(:student).where(student: { id: student_ids }).delete_all

      ActsAsTaggableOn::Tagging.where(
        taggable_type: "Student",
        taggable_id: student_ids
      ).delete_all

      Student.where(id: student_ids).delete_all
      Team.where(cohort_id: cohort_ids).delete_all

      @course.update!(default_cohort_id: nil)
      Cohort.where(id: cohort_ids).delete_all
    end
  end
end
