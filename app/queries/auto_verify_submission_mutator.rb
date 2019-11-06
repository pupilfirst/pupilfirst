class AutoVerifySubmissionMutator < ApplicationQuery
  include AuthorizeStudent

  property :target_id, validates: { presence: { message: 'Blank Target Id' } }

  validate :can_be_auto_verified
  validate :ensure_submittability

  def create_submission
    target.timeline_events.create!(
      founders: founders,
      description: description,
      passed_at: Time.zone.now,
      latest: true
    )
  end

  private

  def can_be_auto_verified
    return if target.evaluation_criteria.empty? && target.quiz.blank?

    errors[:base] << 'The target cannot be auto verified'
  end

  def description
    "Target '#{target.title}' was automatically marked complete."
  end
end
