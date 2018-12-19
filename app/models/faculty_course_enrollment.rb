class FacultyCourseEnrollment < ApplicationRecord
  attr_accessor :safe_to_create

  belongs_to :faculty
  belongs_to :course

  validate :must_be_safe_to_create

  def must_be_safe_to_create
    return if persisted?
    return if safe_to_create

    errors[:base] << 'is not safe to create'
  end
end
