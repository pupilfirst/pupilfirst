class MoocStudent < ActiveRecord::Base
  belongs_to :user
  belongs_to :university

  GENDER_MALE = -'male'
  GENDER_FEMALE = -'female'
  GENDER_OTHER = -'other'

  def self.valid_gender_values
    [GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]
  end

  validates :gender, inclusion: { in: valid_gender_values }

  validates_uniqueness_of :user_id

  validates_presence_of :name, :university_id, :college, :semester, :state

  before_save :copy_email_from_user

  def copy_email_from_user
    return unless user.present? && user_id_changed?

    self.email = user.email
  end

  def details_complete?
    [name, gender, university_id, college, semester, state].reject { |c| c.blank? }.length == 6
  end
end
