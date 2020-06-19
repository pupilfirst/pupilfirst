class TargetGroup < ApplicationRecord
  # Use to allow archival of a target group. See TargetGroups::ArchivalService.
  attr_accessor :safe_to_archive

  has_many :targets, dependent: :restrict_with_error
  belongs_to :level
  has_one :course, through: :level

  validates :name, presence: true
  validates :sort_index, presence: true

  validate :must_be_safe_to_archive

  def must_be_safe_to_archive
    return unless archived_changed? && archived?
    return if safe_to_archive

    errors[:archived] << 'cannot be set unsafely'
  end

  def display_name
    "#{course.short_name}##{level.number}: #{name}"
  end
end
