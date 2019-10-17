class UpdateReviewChecklistMutator < ApplicationMutator
  include AuthorizeCoach

  attr_accessor :target_id
  attr_accessor :review_checklist

  validates :target_id, presence: true
  validate :review_checklist_shape

  def update_review_checklist
    target.update!(review_checklist: review_checklist_json)
  end

  private

  def review_checklist_shape
    return if review_checklist_json.all? do |item|
      item['title'].is_a?(String) && item['checklist'].all? do |result|
        result['title'].is_a?(String) && result['feedback'].is_a?(String)
      end
    end

    errors[:base] << 'Invalid review checklist'
  end

  def review_checklist_json
    @review_checklist_json ||= JSON.parse(review_checklist)
  rescue JSON::ParserError
    errors[:base] << "Review checklist is not a valid JSON string"
  end

  def target
    @target = current_school.targets.find_by(id: target_id)
  end

  def course
    @course ||= target&.course
  end
end
