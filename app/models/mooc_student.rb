class MoocStudent < ActiveRecord::Base
  belongs_to :university
  belongs_to :user

  GENDER_MALE = -'male'
  GENDER_FEMALE = -'female'
  GENDER_OTHER = -'other'

  def self.valid_gender_values
    [GENDER_FEMALE, GENDER_MALE, GENDER_OTHER]
  end

  attr_accessor :skip_validation

  validates :gender, inclusion: { in: valid_gender_values }, unless: :skip_validation

  validates_uniqueness_of :user_id, unless: :skip_validation

  validates_presence_of :name, :university_id, :college, :semester, :state, unless: :skip_validation

  before_save :copy_email_from_user

  def copy_email_from_user
    return unless user.present? && user_id_changed?

    self.email = user.email
  end

  def details_complete?
    [name, gender, university_id, college, semester, state].count(&:present?) == 6
  end
end
