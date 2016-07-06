class MoocStudent < ActiveRecord::Base
  belongs_to :user

  GENDER_MALE = -'male'
  GENDER_FEMALE = -'female'
  GENDER_OTHER = -'other'

  def self.valid_gender_values
    [GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]
  end

  validates :gender, inclusion: { in: valid_gender_values }

  validates_uniqueness_of :user_id
end
