module Admin
  class TimelineEventStatusUpdateForm < Reform::Form
    property :grade, validates: { inclusion: { in: TimelineEvent.valid_grades }, allow_blank: true }
    property :points, virtual: true
    property :verified_status, validates: { presence: true, inclusion: { in: TimelineEvent.valid_verified_status } }

    validate :grade_provided_if_and_only_if_required

    def grade_provided_if_and_only_if_required
      return unless model.target&.points_earnable.present?

      if verified_status == TimelineEvent::VERIFIED_STATUS_VERIFIED
        errors[:grade] << 'is required if being verified.' unless grade.present?
      elsif grade.present?
        errors[:grade] << 'should not be specified for the given status.'
      end
    end

    def save
      if points.present?
        TimelineEvents::VerificationService.new(model).update_status(verified_status, points: points)
      elsif grade.present?
        TimelineEvents::VerificationService.new(model).update_status(verified_status, grade: grade)
      else
        raise 'Unexpected arguments!'
      end
    end
  end
end
