class MoocStudent < ActiveRecord::Base
  belongs_to :university
  belongs_to :user

  has_many :quiz_attempts
  has_many :course_chapters, through: :quiz_attempts

  def self.valid_semester_values
    %w(I II III IV V VI VII VIII Graduated Other)
  end
end
