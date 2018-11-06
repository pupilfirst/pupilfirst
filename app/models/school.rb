class School < ApplicationRecord
  validates :name, presence: true
  validates :max_grade,  numericality: { greater_than: 0 }
  validates :pass_grade, numericality: { greater_than: 0, less_than_or_equal_to: :max_grade }
  validate :grade_labels_must_match_grades

  has_many :levels, dependent: :restrict_with_error
  has_many :target_groups, through: :levels
  has_many :targets, through: :target_groups
  has_many :skills, dependent: :restrict_with_error

  def short_name
    name[0..2].upcase.strip
  end

  def facebook_share_disabled?
    name.include? 'Apple'
  end

  # Hack to enable editing grade_labels as an activeadmin text field
  def grade_labels=(labels)
    labels.is_a?(String) ? super(JSON.parse(labels)) : super(labels)
  end

  private

  def grade_labels_must_match_grades
    return if grade_labels.keys.map(&:to_i) == [*1..max_grade]

    errors[:grade_labels] << 'do not match available grades'
  end
end
