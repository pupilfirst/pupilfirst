class Mentor < ActiveRecord::Base
  MAX_SKILL_COUNT = 3

  CTC_BELOW_3L = 150000
  CTC_BETWEEN_3L_AND_6L = 450000
  CTC_BETWEEN_6L_AND_12L = 900000
  CTC_BETWEEN_12L_AND_36L = 2400000
  CTC_BETWEEN_36L_AND_1CR = 6800000
  CTC_ABOVE_1_CR = 10000000

  DONATE_100 = 100
  DONATE_75 = 75
  DONATE_50 = 50
  DONATE_25 = 25
  DONATE_0 = 0

  belongs_to :user
  belongs_to :company
  accepts_nested_attributes_for :user
  has_many :skills, class_name: 'MentorSkill'

  validates_presence_of :user
  validates_presence_of :company
  validates_associated :user
  validates_presence_of :time_availability
  validates_presence_of :company_level
  validates_presence_of :cost_to_company
  validates_presence_of :time_donate_percentage

  validate :skill_count_must_be_less_than_max

  def skill_count_must_be_less_than_max
    if self.skills.count > MAX_SKILL_COUNT
      self.errors.add(:skills, "Can't list more than 3 skills")
    end
  end
end
