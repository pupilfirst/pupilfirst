module TimelineEvents
  class CreateWebhookDataService
    def initialize(submission)
      @submission = submission
    end

    def data
      {
        id: @submission.id,
        students: @submission.students.pluck(:id),
        created_at: @submission.created_at,
        updated_at: @submission.updated_at,
        target_id: @submission.target_id,
        checklist: @submission.checklist,
        level_number: target.level.number,
        target: {
          id: target.id,
          title: target.title,
          evaluation_criteria: evaluation_criteria
        },
        files: files
      }.merge(evaluation)
    end

    def students
      @submission.students.map do |student|
        { id: student.id, name: student.name }
      end
    end

    def evaluation
      return {} if evaluation_criteria.empty? || @submission.pending_review?

      {
        evaluator: @submission.evaluator.name,
        evaluated_at: @submission.evaluated_at,
        grades:
          @submission
            .timeline_event_grades
            .each_with_object({}) do |submission_grade, evaluation|
              evaluation[submission_grade.evaluation_criterion_id] =
                submission_grade.grade
              evaluation
            end
      }
    end

    def target
      @submission.target
    end

    def evaluation_criteria
      @evaluation_criteria ||=
        @submission.evaluation_criteria.map do |ec|
          {
            id: ec.id,
            name: ec.name,
            max_grade: ec.max_grade,
            grade_labels: ec.grade_labels
          }
        end
    end

    def files
      @submission.timeline_event_files.map do |timeline_event_file|
        file = timeline_event_file.file

        file_path =
          Rails.application.routes.url_helpers.rails_public_blob_url(file)

        file_url =
          if ENV['CLOUDFRONT_HOST'].present? && Rails.env.production?
            file_path
          else
            "https://#{school.domains.primary.fqdn}#{file_path}"
          end

        {
          filename: file.filename.to_s,
          content_type: file.content_type,
          byte_size: file.byte_size,
          checksum: file.checksum,
          url: file_url
        }
      end
    end

    def school
      @school ||= @submission.course.school
    end
  end
end
