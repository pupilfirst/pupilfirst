class UpdateReviewChecklistMutator < ApplicationMutator
  include AuthorizeCoach

  attr_accessor :target_id
  attr_accessor :review_checklist

  validates :target_id, presence: true
  validate :review_checklist_shape

  def update_review_checklist
    target.update!(review_checklist: review_checklist)
  end

  private

  # rubocop: disable Metrics/CyclomaticComplexity
  def review_checklist_shape
    return if review_checklist.respond_to?(:all?) && review_checklist.all? do |item|
      item['title'].is_a?(String) && item['result'].respond_to?(:all?) && item['result'].all? do |result|
        result['title'].is_a?(String) && (result['feedback'].nil? || result['feedback'].is_a?(String))
      end
    end

    errors[:base] << 'Invalid review checklist'
  end

  # rubocop: enable  Metrics/CyclomaticComplexity

  def target
    @target = current_school.targets.find_by(id: target_id)
  end

  def course
    @course ||= target&.course
  end
end
