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
        }
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
  end
end
