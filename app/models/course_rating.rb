class CourseRating < ApplicationRecord
  belongs_to :course
  belongs_to :user

  validates :rating, presence: true
  validates :rating, numericality: { only_integer: true }
  validates :rating, inclusion: { in: 1..5 }
  validates :course_id,
            uniqueness: {
              scope: :user_id,
              message: I18n.t("models.course_rating.already_rated")
            }
end
