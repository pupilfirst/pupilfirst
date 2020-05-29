class UpdateReviewChecklistMutator < ApplicationQuery
  include AuthorizeCoach

  property :target_id, validates: { presence: true }
  property :review_checklist

  validate :review_checklist_shape

  def update_review_checklist
    Target.transaction do
      target.resource_versions.create!(value: target.review_checklist)
      target.update!(review_checklist: review_checklist)
    end
  end

  private

  def review_checklist_shape
    return if review_checklist.respond_to?(:all?) && review_checklist.all? do |item|
      valid_title?(item['title']) && item['result'].respond_to?(:all?) && item['result'].all? do |result|
        valid_title?(result['title']) && (result['feedback'].nil? || result['feedback'].is_a?(String))
      end
    end

    errors[:base] << 'Invalid review checklist'
  end


  def valid_title?(title)
    title.is_a?(String) && title.present?
  end

  def target
    @target = Target.find_by(id: target_id)
  end

  def course
    @course ||= target&.course
  end
end
