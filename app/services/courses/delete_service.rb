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
        delete_faculty_course_enrollments
        delete_levels

        @course.reload.destroy!
      end
    end

    private

    def delete_applicants
      Applicant.where(course_id: @course.id).delete_all
    end

    def delete_certificates
      IssuedCertificate.where(course: @course.certificates).delete_all
      @course.certificates.destroy_all
    end

    def delete_community_course_connections
      CommunityCourseConnection.where(course_id: @course.id).delete_all
    end

    def delete_course_authors
      CourseAuthor.joins(:course).where(courses: { id: @course.id }).delete_all
    end

    def delete_course_exports
      ActsAsTaggableOn::Tagging.where(taggable_type: 'CourseExport', taggable_id: @course.course_exports.select(:id)).delete_all
      @course.course_exports.destroy_all
    end

    def delete_evaluation_criteria
      TargetEvaluationCriterion.where(evaluation_criteria: @course.evaluation_criteria).delete_all
      TimelineEventGrade.where(evaluation_criteria: @course.evaluation_criteria).delete_all
      EvaluationCriterion.where(course_id: @course.id).delete_all
    end

    def delete_faculty_course_enrollments
      @course.faculty_course_enrollments.delete_all
    end

    def delete_levels
      delete_submissions
      delete_teams
      delete_content

      Level.where(course_id: @course.id).delete_all
    end

    def delete_submissions
      submissions = TimelineEvent.joins(founder: :course).where(courses: { id: @course.id })

      TimelineEventFile.where(timeline_event_id: submissions).delete_all
      TimelineEventOwner.where(timeline_event_id: submissions).delete_all

      submissions.delete_all
    end

    def delete_content
      AnswerOption.joins(quiz_question: { quiz: { target: :course } }).where(courses: { id: @course.id }).delete_all
      QuizQuestion.joins(quiz: { target: :course }).where(courses: { id: @course.id }).delete_all
      Quiz.joins(target: :course).where(courses: { id: @course.id }).delete_all
      ContentBlock.joins(target_version: { target: :course }).where(courses: { id: @course.id }).delete_all
      TargetVersion.joins(target: :course).where(courses: { id: @course.id }).delete_all
      TargetPrerequisite.joins(target: :course).where(courses: { id: @course.id }).delete_all
      ResourceVersion.where(versionable_type: 'Target', versionable_id: @course.targets.select(:id)).delete_all
      Target.joins(:course).where(courses: { id: @course.id }).delete_all
      TargetGroup.joins(:course).where(courses: { id: @course.id }).delete_all
    end

    def delete_teams
      startup_ids = @course.startups.select(:id)

      ActsAsTaggableOn::Tagging.where(taggable_type: 'Startup', taggable_id: startup_ids).delete_all
      FacultyStartupEnrollment.where(startup_id: startup_ids).delete_all
      CoachNote.joins(student: :startup).where(startups: { id: startup_ids }).delete_all
      LeaderboardEntry.joins(founder: :startup).where(startups: { id: startup_ids }).delete_all
      Founder.where(startup_id: startup_ids).delete_all
      StartupFeedback.where(startup_id: startup_ids).delete_all
      Startup.where(id: startup_ids).delete_all
    end
  end
end
