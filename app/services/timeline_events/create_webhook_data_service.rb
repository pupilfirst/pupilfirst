module TimelineEvents
  class CreateWebhookDataService
    def initialize(submission)
      @submission = submission
    end

    def data
      {
        id: @submission.id,
        created_at: @submission.created_at,
        updated_at: @submission.updated_at,
        target_id: @submission.target_id,
        checklist: @submission.checklist,
        target: {
          id: target.id,
          title: target.title,
          evaluation_criteria: evaluation_criteria
        },
        files: files
      }
    end

    private

    def target
      @target ||= @submission.target
    end

    def evaluation_criteria
      @submission.evaluation_criteria.map do |ec|
        {
          name: ec.name,
          max_grade: ec.max_grade,
          pass_grade: ec.pass_grade,
          grade_labels: ec.grade_labels
        }
      end
    end

    def files
      @submission.timeline_event_files.map do |timeline_event_file|
        file = timeline_event_file.file
        file_path = Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)

        {
          filename: file.filename.to_s,
          content_type: file.content_type,
          byte_size: file.byte_size,
          checksum: file.checksum,
          url: "https://#{school.domains.primary.fqdn}#{file_path}"
        }
      end
    end

    def school
      @school ||= @submission.course.school
    end
  end
end
