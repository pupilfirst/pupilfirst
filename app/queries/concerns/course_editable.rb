module CourseEditable
  extend ActiveSupport::Concern

  included do
    property :name, validates: { presence: true, length: { minimum: 1, maximum: 50 } }
    property :description, validates: { presence: true, length: { minimum: 1, maximum: 150 } }
    property :ends_at
    property :public_signup
    property :about, validates: { length: { maximum: 10_000 } }
    property :featured
    property :progression_behavior, validates: { inclusion: { in: Course::VALID_PROGRESSION_BEHAVIORS } }
    property :progression_limit, validates: { numericality: { min: 1, max: 3, allow_nil: true } }

    validate :limited_progression_requires_details
  end

  def limited_progression_requires_details
    return unless progression_behavior == Course::PROGRESSION_BEHAVIOR_LIMITED

    return if progression_limit.present?

    errors[:base] << 'Progression limit must be specified when the course progression is limited'
  end

  def sanitized_progression_limit
    progression_behavior == Course::PROGRESSION_BEHAVIOR_LIMITED ? progression_limit : nil
  end
end
